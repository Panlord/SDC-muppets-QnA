/* eslint-disable spaced-comment */
// Helper functions to query the Postgres database

// Import stuff
const { Pool } = require('pg');

// Connect to the Postgres database
const pool = new Pool({
  database: 'qna',
});

////////////////////////
// Database Functions //
////////////////////////

// Function to get all the questions for a specific product
const getAllQuestions = (productId) => {
  const queryString = `SELECT ARRAY_AGG (JSON_BUILD_OBJECT (
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
  WHERE questions.product_id=${productId} AND questions.reported=false;`;
  return pool.query(queryString);
};

// Function to get the answers for a specific question
const getAllAnswers = (questionId) => {
  const queryString = `SELECT ARRAY_AGG(JSON_BUILD_OBJECT (
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
  WHERE answers.question_id=${questionId} AND answers.reported=false;`;
  return pool.query(queryString);
};

// Export helper functions
module.exports = {
  getAllQuestions,
  getAllAnswers,
};
