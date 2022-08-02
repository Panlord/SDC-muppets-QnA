/* eslint-disable camelcase */
/* eslint-disable max-len */
// The routes for the QnA API

// Import stuff
require('dotenv').config();
const QnARouter = require('express').Router();
const format = require('pg-format');
const QnAAPI = require('./helpers/QnAPostgresDB.js');

// GET all the questions for a particular product
QnARouter.get('/questions', (request, response) => {
  QnAAPI.getAllQuestions(request.query.product_id, request.query.page, request.query.count)
    .then((results) => {
      // results.rows = [] of objects of objects; has key results, value = [] of question objects
      const queryResults = {
        product_id: request.query.product_id,
        results: results.rows[0].array_agg,
      };
      response.status(200).send(queryResults);
    })
    .catch((error) => {
      response.status(500).send(error);
    });
});

// POST a question for a particular product
QnARouter.post('/questions', (request, response) => {
  const questionData = {
    body: request.body.body,
    name: request.body.name,
    email: request.body.email,
    product_id: request.body.product_id,
  };
  QnAAPI.addQuestion(questionData)
    .then(() => {
      response.status(201).send();
    })
    .catch((error) => {
      response.status(500).send(error);
    });
});

// PUT an update to +1 a question's helpfulness
QnARouter.put('/questions/:question_id/helpful', (request, response) => {
  QnAAPI.helpfulnessAddOne('questions', request.params.question_id)
    .then(() => {
      response.status(204).send();
    })
    .catch((error) => {
      response.status(500).send(error);
    });
});

// PUT a report on a question
QnARouter.put('/questions/:question_id/report', (request, response) => {
  QnAAPI.markReportedTrue('questions', request.params.question_id)
    .then(() => {
      response.status(204).send();
    })
    .catch((error) => {
      response.status(500).send(error);
    });
});

// GET all the answers for a given question
QnARouter.get('/questions/:question_id/answers', (request, response) => {
  QnAAPI.getAllAnswers(request.params.question_id, request.query.page, request.query.count)
    .then((results) => {
      const allAnswerData = {
        question: `${request.params.question_id}`,
        page: request.query.page,
        count: request.query.count,
        results: results.rows[0].array_agg,
      };
      response.send(allAnswerData);
    })
    .catch((error) => {
      response.status(500).send(error);
    });
});

// POST an answer for a particular product
QnARouter.post('/questions/:question_id/answers', (request, response) => {
  const answerData = {
    body: request.body.body,
    name: request.body.name,
    email: request.body.email,
    question_id: request.params.question_id,
  };
  // const answerData = [request.body.body, new Date(), request.body.name, request.body.email, parseInt(request.params.question_id, 10)];
  QnAAPI.addAnswer(answerData)
    .then((results) => results.rows[0].answer_id)
    .then((answer_id) => QnAAPI.addPhoto(answer_id, request.body.photos))
    .then(() => {
      response.status(201).send();
    })
    .catch((error) => {
      response.status(500).send(error);
    });
});

// PUT an update to +1 an answer's helpfulness
QnARouter.put('/answers/:answer_id/helpful', (request, response) => {
  QnAAPI.helpfulnessAddOne('answers', request.params.answer_id)
    .then(() => {
      response.status(204).send();
    })
    .catch((error) => {
      response.status(500).send(error);
    });
});

// PUT a report on an answer
QnARouter.put('/answers/:answer_id/report', (request, response) => {
  QnAAPI.markReportedTrue('answers', request.params.answer_id)
    .then(() => {
      response.status(204).send();
    })
    .catch((error) => {
      response.status(500).send(error);
    });
});

// A POST request for testing purposes
QnARouter.post('/test/:id/all/:page', (request, response) => {
  let obj = {
    id: request.params.id,
    page: request.params.page,
    body: request.body,
  };
  const queryString = `INSERT INTO answers (answer_body, answer_date, answerer_name, answerer_email, question_id)
  VALUES %L
  RETURNING answer_id;`;
  var values = [];
  for (let i = 0; i < request.body.photos.length; i += 1) {
    values.push([i, request.body.photos[i]]);
  }
  console.log(format(queryString, values));
  response.send(obj);
});

module.exports = QnARouter;
