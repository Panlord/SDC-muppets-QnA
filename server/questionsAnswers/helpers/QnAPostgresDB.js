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
  const queryString = `SELECT * FROM questions WHERE product_id=${productId};`;
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
  WHERE answers.question_id=${questionId};`;
  return pool.query(queryString);
};

// Export helper functions
module.exports = {
  getAllQuestions,
  getAllAnswers,
};
