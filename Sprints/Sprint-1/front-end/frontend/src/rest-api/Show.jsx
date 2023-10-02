import React, { useState, useEffect } from 'react';
import BASE_URL from "./config";

function Show() {
  const [entries, setEntries] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [isLoading, setIsLoading] = useState(false);
  const [displayData, setDisplayData] = useState(false);

  useEffect(() => {
    if (displayData) {
      fetchData();
    }
    });

  const fetchData = () => {
    setIsLoading(true);
    try {
      fetch(`${BASE_URL}/get_data?page=${currentPage}`)
        .then((response) => {
          if (!response.ok) {
            throw new Error(response.statusText);
          }
          return response.json();
        })
        .then((data) => {
          setEntries(data.entries);
          setIsLoading(false);
        })
        .catch((error) => {
          console.error('Error fetching data:', error);
          setIsLoading(false);
        });
    } catch (error) {
      console.error('Error occurred during fetch:', error);
    }
  };

  const handleDisplayData = () => {
    setDisplayData(true);
  };

  const handleNextPage = () => {
    setCurrentPage((prevPage) => prevPage + 1);
  };

  const handlePreviousPage = () => {
    setCurrentPage((prevPage) => prevPage - 1);
  };

  return (
    <div style={{ fontFamily: 'Arial, sans-serif', maxWidth: '800px', margin: '0 auto' }}>
      <h1 style={{ textAlign: 'center', marginBottom: '20px' }}>Show App - Entries from Flask</h1>
      {!displayData ? (
        <div style={{ textAlign: 'center' }}>
          <button onClick={handleDisplayData} style={{ padding: '10px 20px', fontSize: '16px', backgroundColor: 'green', color: '#fff', border: 'none', cursor: 'pointer' }}>Display Data</button>
        </div>
      ) : (
        <>
          {isLoading ? (
            <p style={{ textAlign: 'center', marginTop: '20px' }}>Loading...</p>
          ) : (
            <>
              {entries.length > 0 && (
                <table style={{ width: '100%', borderCollapse: 'collapse', marginTop: '20px', border: '1px solid green' }}>
                  <thead style={{ backgroundColor: 'green', color: '#fff' }}>
                    <tr>
                      <th style={{ padding: '10px', border: '1px solid green' }}>ID</th>
                      <th style={{ padding: '10px', border: '1px solid green' }}>Data</th>
                      <th style={{ padding: '10px', border: '1px solid green' }}>Timestamp</th>
                      <th style={{ padding: '10px', border: '1px solid green' }}>Frequency</th>
                      <th style={{ padding: '10px', border: '1px solid green' }}>Hours</th>
                      <th style={{ padding: '10px', border: '1px solid green' }}>Thread ID</th>
                    </tr>
                  </thead>
                  <tbody>
                    {entries.map((entry) => (
                      <tr key={entry.id} style={{ borderBottom: '1px solid green', marginBottom: '10px', paddingBottom: '10px' }}>
                        <td style={{ padding: '10px', border: '1px solid green' }}>{entry.id}</td>
                        <td style={{ padding: '10px', whiteSpace: 'pre-wrap', border: '1px solid green', fontSize: '12px' }}>
                          {JSON.stringify(entry.data, null, 2)}
                        </td>
                        <td style={{ padding: '10px', border: '1px solid green' }}>{entry.timestamp}</td>
                        <td style={{ padding: '10px', border: '1px solid green' }}>{entry.frequency}</td>
                        <td style={{ padding: '10px', border: '1px solid green' }}>{entry.hours}</td>
                        <td style={{ padding: '10px', border: '1px solid green' }}>{entry.thread_id}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
              <div style={{ textAlign: 'center', marginTop: '20px' }}>
                <button onClick={handlePreviousPage} style={{ padding: '10px 20px', fontSize: '16px', backgroundColor: 'green', color: '#fff', border: 'none', cursor: 'pointer', marginRight: '10px' }} disabled={currentPage === 1}>Previous</button>
                <button onClick={handleNextPage} style={{ padding: '10px 20px', fontSize: '16px', backgroundColor: 'green', color: '#fff', border: 'none', cursor: 'pointer' }} disabled={entries.length < 3}>Next</button>
              </div>
            </>
          )}
        </>
      )}
    </div>
  );
}

export default Show;
