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

// Export helper functions
module.exports = {
  getAllQuestions,
};
