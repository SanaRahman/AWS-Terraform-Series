import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import ApiCaller from './rest-api/ApiCaller';
import Show from './rest-api/Show';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
      < ApiCaller />
      < Show />
  </React.StrictMode>

);
