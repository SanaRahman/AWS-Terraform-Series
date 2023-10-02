from flask import Flask, request, jsonify
import requests
import threading
import time
import psycopg2
import json
from flask_cors import CORS
import os
from dotenv import load_dotenv
import math
import logging


app = Flask(__name__)
CORS(app)
load_dotenv()
log = logging.getLogger()
log.setLevel(logging.INFO)


DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASSWORD = os.environ.get("DB_PASSWORD")
DB_HOST = os.environ.get("DB_HOST", 'host.docker.internal')
DB_PORT = os.environ.get("DB_PORT")


def create_table():
    """
    Creates a database table named 'api' if it doesn't exist.

    This function establishes a connection to the database using the provided
    environment variables and executes an SQL query to create the table.

    Returns:
        None
    """
    try:
        # Database connection
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT,
        )

        # Create the table if it does not exist
        create_table_query = """
        CREATE TABLE IF NOT EXISTS api (
              id SERIAL PRIMARY KEY,
              data JSON,
              timestamp TIMESTAMP DEFAULT NOW(),
              frequency FLOAT,
              hours INTEGER,
              thread_id TEXT
        );
        """

        with conn:
            with conn.cursor() as cursor:
                cursor.execute(create_table_query)

    except Exception as e:
        # Handle the exception if the table creation fails
        log.error(f"An error occurred while creating the table: {e}")

    finally:
        # Close the database connection if it was opened successfully
        if conn:
            conn.close()


# Create the database table on application startup
create_table()


@app.route('/fetch', methods=['POST'])
def fetch_data():
    """
    Fetches data from a given API endpoint and stores it in the database.

    This function takes parameters from the incoming request, validates it,
    calculates the total number of API calls to be made,
    and spawns a separate thread to perform the data fetching and storage

    Returns:
        json: A JSON response indicating the status of data fetching.
    """
    data = request.get_json()
    # Input validation
    try:
        duration = int(data.get('duration'))
        # Parse frequency to float
        frequency_per_hour = float(data.get('frequency'))
    except (ValueError, TypeError):
        return jsonify({'error': 'Invalid duration or frequency.'}), 400

    api_url = data.get('apiEndpoint')
    if not isinstance(api_url, str) or not api_url.startswith('http'):
        return (jsonify
                ({'error': 'Invalid API endpoint. Provide a valid URL \
                  with "http" or "https".'}), 400)

    total_calls = math.ceil(frequency_per_hour * duration)

    def fetch_data():
        try:
            thread_id = threading.get_ident()

            conn = psycopg2.connect(
                dbname=DB_NAME,
                user=DB_USER,
                password=DB_PASSWORD,
                host=DB_HOST,
                port=DB_PORT
            )
            cur = conn.cursor()

            for _ in range(total_calls):
                try:
                    response = requests.get(api_url)
                    response.raise_for_status()
                    # Raise HTTPError for bad responses
                    json_data = response.json()
                    json_string = json.dumps(json_data)

                    insert_query = (
                        "INSERT INTO api_data "
                        "(data, frequency, hours, thread_id) "
                        "VALUES (%s, %s, %s, %s);"
                    )
                    values = (
                        json_string,
                        frequency_per_hour,
                        duration,
                        thread_id
                    )
                    cur.execute(insert_query, values)
                    conn.commit()

                except requests.exceptions.RequestException as re:
                    log.error(f'Error occurred during API request: {re}')
                except Exception as e:
                    log.eror(f'An error occurred while processing data: {e}')

                time.sleep(3600 / frequency_per_hour)

            cur.close()
            conn.close()
        except psycopg2.Error as pg_error:
            log.error(f'Error occurred connecting to database: {pg_error}')
        except Exception as e:
            log.error(f'An unexpected error occurred: {e}')

    try:
        response = requests.get(api_url)
        response.raise_for_status()  # Raise HTTPError for bad responses
        # Create and start the fetch/display thread
        fetch_thread = threading.Thread(target=fetch_data)
        fetch_thread.start()
        return json.dumps('Data fetching and display started!'), 200
    except requests.exceptions.RequestException as re:
        return json.dumps({'error': f'Error during API request: {re}'}), 500
    except Exception as e:
        return json.dumps({'error': f'An error occurred: {e}'}), 500


def fetch_entries(page, en_page):
    """
    Fetches entries from the database.

    Parameters:
        page (int): The page number of entries to fetch.
        en_page (int): The number of entries per page.

    Returns:
        list: A list of entries fetched from the database.
    """
    s = (page - 1) * en_page
    try:
        conn = psycopg2.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )

        with conn.cursor() as cursor:
            cursor.execute(
                f"SELECT * FROM api_data ORDER BY id DESC LIMIT \
                {en_page} OFFSET {s};"
            )
            entries = cursor.fetchall()

        conn.close()
        return entries
    except psycopg2.Error as pg_error:
        log.error(f'Error while connecting to the database: {pg_error}')
        return []  # or return an empty list to indicate no entries
    except Exception as e:
        log.error(f'An unexpected error occurred: {e}')
        return []  # or return an empty list to indicate no entries


@app.route('/get_data', methods=['GET'])
def get_entries():
    """
    Retrieves entries from the database and returns them as a JSON response.

    This function handles GET requests to retrieve entries from the 'api_data'
    table in the database. It accepts an optional 'page' parameter to paginate
    the results and returns a JSON response containing the fetched entries and
    pagination information.

    Returns:
        json: A JSON response containing entries and pagination information.
    """
    try:
        page = int(request.args.get('page', 1))
        en_page = 3

        entries = fetch_entries(page, en_page)
        has_next = len(entries) == en_page

        api_responses = []
        for row in entries:
            api_response = {
                'id': row[0],
                'data': row[1],
                'timestamp': row[2],
                'frequency': row[3],
                'hours': row[4],
                'thread_id': row[5]
            }
            api_responses.append(api_response)

        data = {'entries': api_responses, 'has_next': has_next}

        return jsonify(data), 200
    except Exception as e:
        return json.dumps({'error': f'An error occurred: {e}'}), 500


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
