// Server file for Question and Answers section of the backend

const express = require('express');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
app.use(express.json());
app.use(express.static(path.join(__dirname, '..', 'client', 'dist')));

app.get('/test', (request, response) => {
  response.send('It works!!');
});

const QnARouter = require('./questionAnswerRoutes.js');

app.use('/qa', QnARouter);

app.listen(PORT, () => {
  console.log(`QnA Server running on ${PORT}`);
});
