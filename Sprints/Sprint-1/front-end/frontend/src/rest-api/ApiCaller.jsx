import React, { useState } from 'react';
import './style_api.css';
import BASE_URL from "./config";

// const apiUrl = process.env.REACT_APP_API_URL || 'https://default-api-url.com';

const ApiCaller = () => {
  const [apiEndpoint, setApiEndpoint] = useState('');
  const [duration, setDuration] = useState(0);
  const [frequency, setFrequency] = useState('');

  const handleApiEndpointChange = (event) => {
    setApiEndpoint(event.target.value);
  };

  const handleDurationChange = (event) => {
    setDuration(Number(event.target.value));
  };

  const handleFrequencyChange = (event) => {
    const value = event.target.value;

    // Validate if the entered value is a valid number (integer or float)
    if (!Number.isNaN(Number(value)) || value === '') {
      setFrequency(value);
    } else {
      alert('Please enter a valid numeric value for frequency.');
    }
  };


  const handleApiCall = () => {
    if (!apiEndpoint || duration <= 0 || parseFloat(frequency) <= 0) {
      alert('Please enter valid inputs.');
      return;
    }

    const requestData = JSON.stringify({
      apiEndpoint,
      duration,
      frequency,
    });


  fetch(`${BASE_URL}/fetch`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: requestData,
  })
    .then((response) => {
      if (!response.ok) {
        throw new Error(response.statusText);
      }
      return response.json();
    })
    .then((response) => {
      alert('Request Successful');
      console.log('API Response:', response);
    })
    .catch((error) => {
      if (error.message === 'Failed to fetch') {
        alert('Error: Network error. Please check your internet connection and try again.');
      } else {
        // Check if response contains JSON data
        if (error.response && error.response.json) {
          error.response.json().then((errorData) => {
            if (errorData && errorData.error) {
              alert(`Error: ${errorData.error}`);
            } else {
              alert(`Invalid API endpoint.`);
            }
          });
        } else {
          alert(`Invalid API endpoint.`);
        }
      }
    });

};
  return (
    <div className="container">
      <h1 className="title">API Caller</h1>
      <div className="form-group">
        <label className="label">API Endpoint:</label>
        <input className="input" type="text" value={apiEndpoint} onChange={handleApiEndpointChange} />
      </div>
      <div className="form-group">
        <label className="label">Duration (hours):</label>
        <input className="input" type="number" value={duration} onChange={handleDurationChange} />
      </div>
      <div className="form-group">
        <label className="label">Frequency:</label>
        <input className="input" type="text" value={frequency} onChange={handleFrequencyChange} />
      </div>
      <button className="button" onClick={handleApiCall}>Call API</button>
    </div>
  );

};

export default ApiCaller;
