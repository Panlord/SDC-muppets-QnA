// The routes for the QnA API

// Import stuff
require('dotenv').config();
const QnARouter = require('express').Router();
const QnAAPI = require('./helpers/QnAPostgresDB.js');

// GET all the questions for a particular product
QnARouter.get('/questions', (request, response) => {
  QnAAPI.getAllQuestions(request.query.product_id)
    .then((results) => {
      // results.rows = [] of objects of objects; has key results, value = [] of question objects
      const queryResults = {
        product_id: request.query.product_id,
        results: results.rows[0].results,
      };
      response.send(queryResults);
    })
    .catch((error) => {
      response.status(500).send(error);
    });
});

// POST a question for a particular product
QnARouter.post('/questions', (request, response) => {

});

// PUT an update to +1 a question's helpfulness
QnARouter.put('/questions', (request, response) => {

});

// PUT a report on a question
QnARouter.put('/questions', (request, response) => {

});

// GET all the answers for a given question
QnARouter.get('/questions/:question_id/answers', (request, response) => {
  QnAAPI.getAllAnswers(request.params.question_id)
    .then((results) => {
      response.send(results.rows[0].array_agg);
      // NEED TO ADD PAGINATION
    })
    .catch((error) => {
      response.status(500).send(error);
    });
});

// POST an answer for a particular product
QnARouter.post('/answers', (request, response) => {

});

// PUT an update to +1 an answer's helpfulness
QnARouter.put('/answers', (request, response) => {

});

// PUT a report on an answer
QnARouter.put('/answers', (request, response) => {

});

// A POST request for testing purposes
QnARouter.post('/test/:id/all/:page', (request, response) => {
  let obj = {
    id: request.params.id,
    page: request.params.page,
    body: request.body,
  };
  response.send(obj);
});

module.exports = QnARouter;
