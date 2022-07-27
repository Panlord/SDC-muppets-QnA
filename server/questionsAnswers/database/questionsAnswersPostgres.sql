CREATE SCHEMA QnASchema;

CREATE TABLE IF NOT EXISTS QnASchema.products (
  product_id INT PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS QnASchema.questions (
  question_id INT PRIMARY KEY,
  question_body VARCHAR(1000) NOT NULL,
  question_date DATE,
  asker_name VARCHAR(60) NOT NULL,
  asker_email VARCHAR(60) NOT NULL,
  helpfulness INT DEFAULT 0,
  reported BOOLEAN DEFAULT false,
  product_id INT,

  FOREIGN KEY (product_id) REFERENCES QnaSchema.products (product_id)
);

CREATE TABLE IF NOT EXISTS QnASchema.answers (
  answer_id INT PRIMARY KEY,
  answer_body VARCHAR(1000) NOT NULL,
  answer_date DATE,
  answerer_name VARCHAR(60) NOT NULL,
  answerer_email VARCHAR(60) NOT NULL,
  helpfulness INT DEFAULT 0,
  reported BOOLEAN DEFAULT false,
  question_id INT,

  FOREIGN KEY (question_id) REFERENCES QnaSchema.questions (question_id)
);

CREATE TABLE IF NOT EXISTS QnASchema.photos (
  photo_id SERIAL PRIMARY KEY,
  photo_url VARCHAR(1000) NOT NULL,
  answer_id INT,

  FOREIGN KEY (answer_id) REFERENCES QnaSchema.answers (answer_id)
)