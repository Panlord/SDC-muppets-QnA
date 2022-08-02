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
WHERE questions.product_id=1 AND questions.reported=false
LIMIT 1
OFFSET 3;

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

/* Add photo(s) to a given answer DONE */
INSERT INTO photos (photo_url, answer_id)
VALUES ('https://images.unsplash.com/photo-1659369016472-5e52b8e5e008?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80', 6879316);

/* Add an answer to a given question DONE */
INSERT INTO answers (answer_body, answer_date, answerer_name, answerer_email, question_id)
VALUES ('TESTING ANSWER~~~!!!!!', now(), 'Anthony', 'FatAnthony@gmail.com', 1)
RETURNING answer_id;

/* Add a question to a given product DONE */
INSERT INTO questions (question_body, question_date, asker_name, asker_email, product_id)
VALUES ('TEST QUESTION!', now(), 'Antonio', 'Ant@inmyroom.com', 1);

/* Helpfulness + 1 to question DONE */
UPDATE questions
SET helpfulness = helpfulness + 1
WHERE question_id=3518965;

/* Mark reported true DONE */
UPDATE answers
SET reported = true
WHERE answer_id=6879315;

/* Getting questions with pagination */
SELECT ARRAY_AGG(results)
FROM (
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
      WHERE answers.question_id=questions.question_id
    )
  ) AS results
  FROM questions
  WHERE questions.product_id=1 AND questions.reported=false
  LIMIT 1
  OFFSET 2
) AS results;

/* Getting answers with pagination */
/* This one is finicky */
SELECT JSON_BUILD_OBJECT (
  'results', (answer_data)
)
FROM (
  SELECT ARRAY_AGG (results) AS results
  FROM (
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
    ) AS results
    FROM answers
    WHERE answers.question_id=1 AND answers.reported=false
    LIMIT 2
    OFFSET 1
  ) AS all_answers
) AS answer_data;
/* Use this one */
SELECT ARRAY_AGG (results) AS results
  FROM (
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
    ) AS results
    FROM answers
    WHERE answers.question_id=1 AND answers.reported=false
    LIMIT 2
    OFFSET 1
  ) AS all_answers