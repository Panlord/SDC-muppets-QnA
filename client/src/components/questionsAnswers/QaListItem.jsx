import React, { useState } from 'react';
import styled from 'styled-components';
import axios from 'axios';
import AnswerSubItem from './AnswerSubItem.jsx';
import byHelpfulness from './utils/byHelpfulness.js';

function QaListItem({ result }) {
  const [answers, setAnswers] = useState(
    Object.entries(result.answers).sort(byHelpfulness),
  );
  const [answerLimit, setAnswerLimit] = useState(2);
  const [areAllAnswersShown, setAreAllAnswersShown] = useState(false);

  function handleLoadMoreBtn(e) {
    if (answerLimit <= 2) {
      setAnswerLimit(answers.length + 1);
    } else {
      setAnswerLimit(2);
    }
    setAreAllAnswersShown(true);
  }

  const [qVote, setQVote] = useState(result.question_helpfulness);
  const [hasVoted, setHasVoted] = useState(
    localStorage.getItem(`hasVoted-question${result.question_id}`) || false,
  );

  function handleVoteQ() {
    axios
      .put(`https://app-hrsei-api.herokuapp.com/api/fec2/hr-rfp/qa/questions/${result.question_id}/helpful`, {}, {
        headers: {
          Authorization: process.env.GITKEY,
        },
      })
      .then(() => {
        setQVote(qVote + 1);
        setHasVoted(true);
        localStorage.setItem(`hasVoted-question${result.question_id}`, true);
      })
      .catch((err) => {
        console.error(err);
      });
  }

  function handleAnswerModal() {
    const dialog = document.querySelector('.add-answer');
    dialog.showModal();
  }

  return (
    <Wrapper>
      <details open>
        <QuestionWrapper>
          <span>
            {result.question_body}
          </span>
          <small>
            Helpful?
            {hasVoted ? 'Yes' : <SubActionBtn type="button" onClick={handleVoteQ}>Yes</SubActionBtn>}
            (
            {qVote}
            )
            <SubActionBtn type="button" onClick={handleAnswerModal}>Add Answer</SubActionBtn>
          </small>
        </QuestionWrapper>
        <AnswerWrapper>
          {answers.slice(0, answerLimit).map((answer) => (
            <AnswerSubItem key={answer[0]} answer={answer} />
          ))}
          {answers.length > 2
            && (
              <button type="button" onClick={handleLoadMoreBtn}>
                {answerLimit === 2
                  ? 'Load More Answers'
                  : 'Collapse Answers'}
              </button>
            )}
        </AnswerWrapper>
      </details>
      <dialog className="add-answer">
        <form method="dialog">
          <h2>🚧🚧🚧 add answer implementation coming soon 🚧🚧🚧</h2>
          <input placeholder="press enter to exit the modal for now" />
        </form>
      </dialog>
    </Wrapper>
  );
}

export default QaListItem;

const Wrapper = styled.article`
`;

const QuestionWrapper = styled.summary`
  font-weight: 900;
  border: 1px solid whitesmoke;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;


  & span::before {
    content: "Q: ";
  }

  & small {
    font-weight: 400;
  font-size: 0.75rem;
  min-width: max-content;
  }
`;

const AnswerWrapper = styled.div`
  max-height: 50vh;
  overflow: auto;
`;

const SubActionBtn = styled.button`
  border: none;
  background: none;
  text-decoration: underline;
  &:hover {
    text-decoration: none;
  }
`;