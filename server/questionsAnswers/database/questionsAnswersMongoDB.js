// Mongoose database
// Import stuff
const mongoose = require('mongoose');
// Connect to the database
mongoose.connect('mongodb://localhost:27017/qna');
const db = mongoose.connection;
db.on('error', console.error.bind(console, 'database connection error'));
db.once('open', () => {
  console.log('Successfully connected to the database');
});

// Create the schemas
const questionSchema = new mongoose.Schema({
  product_id: Number,
  question_id: { type: Number, unique: true },
  question_body: String,
  question_date: { type: Date, default: Date.now },
  asker_name: String,
  asker_email: String,
  helpfulness: { type: Number, default: 0 },
  reported: { type: Boolean, default: false },
  answers: [Number],
});

const answerSchema = new mongoose.Schema({
  answer_id: { type: Number, unique: true },
  answer_body: String,
  answer_date: { type: Date, default: Date.now },
  answerer_name: String,
  answerer_email: String,
  helpfulness: { type: Number, default: 0 },
  reported: { type: Boolean, default: false },
  photos: [String],
  question_id: Number,
});

// Compile the schemas into models
const Questions = mongoose.model('Question', questionSchema);
const Answers = mongoose.model('Answer', answerSchema);

// Export stuff
