/* eslint-disable prefer-const */
/* eslint-disable no-plusplus */
/* eslint-disable camelcase */
/* eslint-disable quotes */
/* eslint-disable spaced-comment */
// Helper functions to query the Postgres database

// Import stuff
const { Pool } = require('pg');
const format = require('pg-format');

// Connect to the Postgres database
const pool = new Pool({
  database: 'qna',
});

////////////////////////
// Database Functions //
////////////////////////

// Function to get all the questions for a specific product
const getAllQuestions = (product_id, page = 1, count = 5) => {
  const queryString = `SELECT ARRAY_AGG(results)
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
    WHERE questions.product_id=${product_id} AND questions.reported=false
    LIMIT ${count}
    OFFSET ${(page - 1) * count}
  ) AS results;`;
  return pool.query(queryString);
};

// Function to add a question for a specific product
const addQuestion = (data) => {
  const queryString = `INSERT INTO questions (question_body, question_date, asker_name, asker_email, product_id)
  VALUES ('${data.body}', now(), '${data.name}', '${data.email}', ${data.product_id});`;
  return pool.query(queryString);
};

// Function to get the answers for a specific question
const getAllAnswers = (question_id, page = 1, count = 5) => {
  const queryString = `SELECT ARRAY_AGG (results)
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
    WHERE answers.question_id=${question_id} AND answers.reported=false
    LIMIT ${count}
    OFFSET ${(page - 1) * count}
  ) AS results;`;
  return pool.query(queryString);
};

// Function to add an answer for a specific question
// Input: an array of values: answer_body, answerer_name, answerer_email, question_id)
const addAnswer = (data) => {
  const queryString = `INSERT INTO answers (answer_body, answer_date, answerer_name, answerer_email, question_id)
  VALUES ('${data.body}', now(), '${data.name}', '${data.email}', ${data.question_id})
  RETURNING answer_id;`;
  return pool.query(queryString);
};

// Function to add a photo for a specific answer
// Inputs: an answer_id (number) and a the photos (array of strings)
const addPhoto = (answer_id, photos) => {
  const queryString = `INSERT INTO photos (answer_id, photo_url)
  VALUES %L;`;
  let values = [];
  for (let i = 0; i < photos.length; i++) {
    values.push([answer_id, photos[i]]);
  }
  return pool.query(format(queryString, values));
};

// Function to update the helpfulness field of either a question or an answer, depending on input
// Inputs: a string (questions or answers) and a number (question/answer id)
const helpfulnessAddOne = (questionOrAnswer, id) => {
  let condition;
  if (questionOrAnswer === 'questions') {
    condition = `question_id=${id}`;
  } else if (questionOrAnswer === 'answers') {
    condition = `answer_id=${id}`;
  }
  const queryString = `UPDATE ${questionOrAnswer}
  SET helpfulness = helpfulness + 1
  WHERE ${condition};`;
  return pool.query(queryString);
};

// Function to update the reported field of a question/answer, depending on input
// Inputs: a string (questions or answers) and a number (question/answer id)
const markReportedTrue = (questionOrAnswer, id) => {
  let condition;
  if (questionOrAnswer === 'questions') {
    condition = `question_id=${id}`;
  } else if (questionOrAnswer === 'answers') {
    condition = `answer_id=${id}`;
  }
  const queryString = `UPDATE ${questionOrAnswer}
  SET reported = true
  WHERE ${condition};`;
  return pool.query(queryString);
};

// Export helper functions
module.exports = {
  getAllQuestions,
  addQuestion,
  getAllAnswers,
  addAnswer,
  addPhoto,
  helpfulnessAddOne,
  markReportedTrue,
};
