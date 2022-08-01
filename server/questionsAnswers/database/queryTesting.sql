/* Join questions with answers on product_id 1; combine all answers into a json object  */
SELECT questions.question_id, question_body, asker_name, asker_email, questions.helpfulness, questions.reported, product_id,
  JSON_AGG (
    (answer_id, answer_body, answer_date, answerer_name, answerer_email, answers.helpfulness, answers.reported))
  answers
FROM questions
INNER JOIN answers
ON questions.question_id=answers.question_id
WHERE questions.product_id=1
GROUP BY questions.question_id
limit 30;

/* Get single answer as key:answer_id value:JSONobj */
SELECT JSON_BUILD_OBJECT (
  answer_id,
  ROW_TO_JSON (answers))
FROM (
  SELECT *
  FROM answers
  WHERE answer_id=5
) AS answers;

/* Get single answer with photos array */
SELECT JSON_AGG (ROW_TO_JSON (answer_photos))
FROM (
  SELECT
    *,
    (
      SELECT ARRAY_AGG (photo_url)
      FROM photos
      WHERE photos.answer_id=answers.answer_id
    ) AS photos
  FROM answers
  WHERE answer_id=5
) AS answer_photos;

/* With proper formatting DONE */
SELECT JSON_BUILD_OBJECT (
  'id', answer_id,
  'body', answer_body,
  'date', answer_date,
  'answerer_name', answerer_name,
  'helpfulness', helpfulness,
  'reported', reported,
  'photos', (
      SELECT COALESCE(ARRAY_AGG (photo_url), array[]::varchar[])
      FROM photos
      WHERE photos.answer_id=answers.answer_id
    )
) AS answer
FROM answers
WHERE answers.answer_id=5;

/* THis returns rows of JSON objects */
SELECT JSON_BUILD_OBJECT (
  answer_id,
  ROW_TO_JSON (answers))
FROM (
  SELECT *
  FROM answers
  WHERE answers.question_id=1
) AS answers;

/* This currently returns a JSON array */
SELECT JSON_AGG (JSON_BUILD_OBJECT (
  answer_id, (
    SELECT JSON_BUILD_OBJECT (
      'id', answer_id,
      'body', answer_body,
      'date', answer_date,
      'answerer_name', answerer_name,
      'helpfulness', helpfulness,
      'reported', reported,
      'photos', (
          SELECT ARRAY_AGG (photo_url)
          FROM photos
          WHERE photos.answer_id=answers.answer_id
        )
    ) AS answer
    FROM answers
    WHERE answers.answer_id=5
  )
))
FROM answers
WHERE answers.question_id=1;
/* ^^I want a JSON object instead */

/* This returns a JSON object but fails when answers.question_id=1 in the nested JSON object */
SELECT JSON_OBJECT_AGG (answer_id, (
    SELECT JSON_BUILD_OBJECT (
      'id', answer_id,
      'body', answer_body,
      'date', answer_date,
      'answerer_name', answerer_name,
      'helpfulness', helpfulness,
      'reported', reported,
      'photos', (
          SELECT ARRAY_AGG (photo_url)
          FROM photos
          WHERE photos.answer_id=answers.answer_id
        )
    ) AS answer
    FROM answers
    WHERE answers.answer_id=5
  )
)
FROM answers
WHERE answers.question_id=1;

/* This returns a JSON object but maps all the data with each other */
SELECT JSON_OBJECT_AGG (answer_id, all_answers)
FROM (
  SELECT JSON_BUILD_OBJECT (
      'id', answer_id,
      'body', answer_body,
      'date', answer_date,
      'answerer_name', answerer_name,
      'helpfulness', helpfulness,
      'reported', reported,
      'photos', (
          SELECT ARRAY_AGG (photo_url)
          FROM photos
          WHERE photos.answer_id=answers.answer_id
        )
    ) AS answer
    FROM answers
    WHERE answers.question_id=1
) AS all_answers,
answers
WHERE answers.question_id=1;

/* This returns a JSON object with all of the answers (photos included) to a given question. DONE  */
SELECT JSON_OBJECT_AGG (answer_id, JSON_BUILD_OBJECT (
  'id', answer_id,
  'body', answer_body,
  'date', answer_date,
  'answerer_name', answerer_name,
  'helpfulness', helpfulness,
  'reported', reported,
  'photos', (
    SELECT COALESCE(ARRAY_AGG (photo_url), array[]::varchar[])
    FROM photos
    WHERE photos.answer_id=answers.answer_id
  )
))
FROM answers
WHERE answers.question_id=1 AND answers.reported=false;
/* Put this inside the query for questions^^^^ */

/* Get single question with answers and photos DONE */
SELECT JSON_BUILD_OBJECT (
  'question_id', questions.question_id,
  'question_body', question_body,
  'question_date', question_date,
  'asker_name', asker_name,
  'helpfulness', helpfulness,
  'reported', reported,
  'answers', (
    SELECT JSON_OBJECT_AGG (answer_id, JSON_BUILD_OBJECT (
      'id', answer_id,
      'body', answer_body,
      'date', answer_date,
      'answerer_name', answerer_name,
      'helpfulness', helpfulness,
      'reported', reported,
      'photos', (
        SELECT COALESCE(ARRAY_AGG (photo_url), array[]::varchar[])
        FROM photos
        WHERE photos.answer_id=answers.answer_id
      )
    ))
    FROM answers
    WHERE answers.question_id=1
  )
) AS question
FROM questions
WHERE questions.question_id=1;

/* Get all questions with answers and photos for a given product DONE */
SELECT ARRAY_AGG (JSON_BUILD_OBJECT (
  'question_id', questions.question_id,
  'question_body', question_body,
  'question_date', question_date,
  'asker_name', asker_name,
  'helpfulness', helpfulness,
  'reported', reported,
  'answers', (
    SELECT JSON_OBJECT_AGG (answer_id, JSON_BUILD_OBJECT (
      'id', answer_id,
      'body', answer_body,
      'date', answer_date,
      'answerer_name', answerer_name,
      'helpfulness', helpfulness,
      'reported', reported,
      'photos', (
        SELECT COALESCE(ARRAY_AGG (photo_url), array[]::varchar[])
        FROM photos
        WHERE photos.answer_id=answers.answer_id
      )
    ))
    FROM answers
    WHERE answers.question_id=questions.question_id
  )
)) AS results
FROM questions
WHERE questions.product_id=1 AND questions.reported=false;

/* Same as above but if answers=null, it is replaced with an empty object */
SELECT ARRAY_AGG (JSON_BUILD_OBJECT (
  'question_id', questions.question_id,
  'question_body', question_body,
  'question_date', question_date,
  'asker_name', asker_name,
  'helpfulness', helpfulness,
  'reported', reported,
  'answers', (
    SELECT COALESCE(JSON_OBJECT_AGG (answer_id, JSON_BUILD_OBJECT (
      'id', answer_id,
      'body', answer_body,
      'date', answer_date,
      'answerer_name', answerer_name,
      'helpfulness', helpfulness,
      'reported', reported,
      'photos', (
        SELECT COALESCE(ARRAY_AGG (photo_url), array[]::varchar[])
        FROM photos
        WHERE photos.answer_id=answers.answer_id
      )
    )), '{}')
    FROM answers
    WHERE answers.question_id=questions.question_id
  )
)) AS results
FROM questions
WHERE questions.product_id=1 AND questions.reported=false;