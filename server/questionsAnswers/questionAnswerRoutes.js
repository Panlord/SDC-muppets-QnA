// The routes for the QnA API

// Import stuff
require('dotenv').config();
const QnARouter = require('express').Router();
const QnAAPI = require('./helpers/QnAPostgresDB.js');

// GET all the questions
QnARouter.get('/questions', (request, response) => {
  QnAAPI.getAllQuestions(request.query.product_id)
    .then((results) => {
      response.send(results.rows);
    })
    .catch((error) => {
      response.status(500).send(error);
    });
});

module.exports = QnARouter;
