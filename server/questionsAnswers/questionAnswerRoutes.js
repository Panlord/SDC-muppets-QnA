// The routes for the QnA API

require('dotenv').config();
const QnARouter = require('express').Router();
const QnAAPI = require('./helpers/QnADB.js');

// GET all the questions
QnARouter.get('/qa/questions/:id/all/:page', getAll);

module.exports = QnARouter;