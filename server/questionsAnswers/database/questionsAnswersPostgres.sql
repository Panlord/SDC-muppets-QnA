/*
I created a total of 4 tables– products, questions, answers, and photos. The products table is there to list out all the products that exist. Each product has a one-to-many relationship with the questions table, which has all of the data originally sent from the API in addition to a reference to the product id from the products table (so product id is a foreign key). The questions have a one-to-many relationship with the answers, so the parallel between the products table and the questions table is the same for the questions table and the answers table– the answers table has all of the original data sent in the API as well as a foreign key reference to a question id. Also it should be noted that I have added email fields to the questions table and answers table. This is because while the API did not originally send any data regarding emails, POST requests to the API included an email parameter so I thought it was worthwhile to store the posted email data. Finally, the answers table as a one-to-many relationship with the photos and thus the photos table has a foreign key reference to an answer id. Why don’t I just include the photos as an array-type field within the answers table? Because having a separate table allows for easier manipulation of data (in my opinion, at least) and it doesn’t hurt because Postgres, being a relational database, maintains relationships such that a foreign key must exist.
*/

DROP TABLE IF EXISTS photos, answers, questions, products;

CREATE TABLE IF NOT EXISTS products (
  product_id SERIAL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS questions (
  question_id SERIAL PRIMARY KEY,
  question_body VARCHAR(1000) NOT NULL,
  question_date DATE,
  asker_name VARCHAR(60) NOT NULL,
  asker_email VARCHAR(60) NOT NULL,
  helpfulness INT DEFAULT 0,
  reported BOOLEAN DEFAULT false,
  product_id INT,

  FOREIGN KEY (product_id) REFERENCES products (product_id)
);

CREATE INDEX questions_mostHelpful ON questions (helpfulness DESC NULLS LAST);

CREATE TABLE IF NOT EXISTS answers (
  answer_id SERIAL PRIMARY KEY,
  answer_body VARCHAR(1000) NOT NULL,
  answer_date DATE,
  answerer_name VARCHAR(60) NOT NULL,
  answerer_email VARCHAR(60) NOT NULL,
  helpfulness INT DEFAULT 0,
  reported BOOLEAN DEFAULT false,
  question_id INT,

  FOREIGN KEY (question_id) REFERENCES questions (question_id)
);

CREATE INDEX answers_mostHelpful ON answers (helpfulness DESC NULLS LAST);

CREATE TABLE IF NOT EXISTS photos (
  photo_id SERIAL PRIMARY KEY,
  photo_url VARCHAR(1000) NOT NULL,
  answer_id INT,

  FOREIGN KEY (answer_id) REFERENCES answers (answer_id)
)