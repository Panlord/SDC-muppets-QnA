CREATE SCHEMA QnASchema;

CREATE TABLE IF NOT EXISTS QnASchema.products (
  product_id INT PRIMARY KEY,
  question_ids INT[]
);

CREATE TABLE IF NOT EXISTS QnASchema.questions (
  question_id INT PRIMARY KEY,
  question_body VARCHAR(1000),
  question_date DATE,
  asker_name VARCHAR(60),
  asker_email VARCHAR(60),
  helpfulness INT,
  reported BOOLEAN,
  answer_ids INT[]
);

CREATE TABLE IF NOT EXISTS QnASchema.answers (
  answer_id INT PRIMARY KEY,
  answer_body VARCHAR(1000),
  answer_date DATE,
  answerer_name VARCHAR(60),
  answerer_email VARCHAR(60),
  helpfulness INT,
  photos VARCHAR(1000)[]
);