/*
  The questions CSV includes the product_id. I want the product_id in a separate table.
  Thus, I will import the questions CSV into a temporary new table before copy specific
  columns from that table to the respective products and questions tables. While this is
  inefficient space-wise, this ETL Process is a one-time thing so I think it is fine.
*/
/* Create the temporary table */
CREATE TABLE IF NOT EXISTS questions_CSV (
  id INT PRIMARY KEY,
  product_id INT,
  body VARCHAR(1000) NOT NULL,
  date_written BIGINT,
  asker_name VARCHAR(60) NOT NULL,
  asker_email VARCHAR(60) NOT NULL,
  reported BOOLEAN DEFAULT false,
  helpfulness INT DEFAULT 0
);
/* Copy the data from questions.csv to the temporary table */
COPY questions_CSV FROM '/Users/apan/Documents/Immersive/SDC/QnA_CSVs/questions.csv' DELIMITER ',' CSV HEADER;
/* Copy the data from the temp table to the products table */
INSERT INTO products (product_id)
SELECT product_id
FROM questions_CSV
ON CONFLICT DO NOTHING;
/* Copy the data from the temp table to the questions table */
INSERT INTO questions (question_id, question_body, question_date, asker_name, asker_email, helpfulness, reported, product_id)
SELECT id, body, to_timestamp(cast(date_written / 1000 as BIGINT))::DATE, asker_name, asker_email, helpfulness, reported, product_id
FROM questions_CSV;
/* Drop the temp table */
DROP TABLE IF EXISTS questions_CSV;

/* The rest of the tables can be copied from their respective CSVs */
/*
  For answers, the answer_date in the CSV is in type Epoch. Thus, I'll update the datatype in the answers table (currently empty and
  of type DATE), before copying in the data. After copying in the data, I'll transform that date column from Epoch back to date.
*/
ALTER TABLE answers ALTER COLUMN answer_date TYPE BIGINT USING answer_date::TEXT::BIGINT;
COPY answers (answer_id, question_id, answer_body, answer_date, answerer_name, answerer_email, reported, helpfulness)
FROM '/Users/apan/Documents/Immersive/SDC/QnA_CSVs/answers.csv' DELIMITER ',' CSV HEADER;
ALTER TABLE answers ALTER COLUMN answer_date TYPE DATE USING (to_timestamp(cast(answer_date / 1000 as BIGINT))::DATE);

COPY photos (photo_id, answer_id, photo_url)
FROM '/Users/apan/Documents/Immersive/SDC/QnA_CSVs/answers_photos.csv' DELIMITER ',' CSV HEADER;