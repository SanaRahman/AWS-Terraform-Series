# API CALLER APPLICATION

## Running the Backend Locally

To run the backend of the "API Caller: Fetch n' Store" project locally, follow these steps:

1. Make sure you have Python 3.x installed on your machine.

2. Clone or download the repository containing the backend code.

3. Navigate to the root directory of the backend project in your terminal.

4. Install the required dependencies by running the following command:

   ```bash
   pip install -r requirments.txt

   ```

5. Set up the required environment variables:
   - Create a `.env` file in the root directory of the backend project.
   - Add the following environment variables to the `.env` file:

     ```bash
     DB_HOST=your_database_host
     DB_NAME=your_database_name
     DB_USER=your_database_user
     DB_PASSWORD=your_database_password

     ```

6. Start the Flask app by running the following command:

   ```bash
   python3 server.py
   ```

7. The backend will now be running on http://localhost:5001, ready to receive API calls from the frontend.

## Dockerization

The backend of the "API Caller: Fetch n' Store" project can also be containerized using Docker. A Dockerfile is provided in the root directory of the project, which automates the containerization process.

To run the backend using Docker, follow these steps:

1. Ensure you have Docker installed on your system.

2. Clone or download the repository containing the backend code.

3. Navigate to the root directory of the backend project in your terminal.

4. Build the Docker image using the following command:

   ```bash
   docker build -t backend .

   ```

5. After the image is built, run a Docker container based on the image with the following command:

   ```bash
   docker run -p 5001:5001  --network host  backend

   ```
   we will add  --network host because our database is on local machine

6. The backend will now be running in a Docker container accessible at http://localhost:5001, ready to receive API calls from the frontend, just like when running locally.

## API Endpoints

- `POST /fetch : Initiates the API calls to the specified endpoint with the given frequency and duration. Expects a JSON payload with the following parameters:
  - `api_endpoint`: The RESTful public API endpoint to call.
  - `frequency_per_hour`: The number of REST calls per hour (frequency).
  - `duration_hours`: The duration for which the REST calls will run.

- `GET /api_responses`: Fetches the latest 20 API responses stored in the database. Returns a JSON array containing the API responses along with their timestamps.

## Dependencies

The backend project relies on the following key dependencies, listed in the `requirements.txt` file:

- Flask: Web framework for handling HTTP requests and responses.
- Requests: HTTP library to make API calls to external endpoints.
- psycopg2-binary: PostgreSQL adapter for database connectivity.
- flask-cors: Flask extension for handling Cross-Origin Resource Sharing (CORS).
- python-dotenv: Library for reading environment variables from the `.env` file.

These dependencies are automatically installed when setting up the project using `pip install -r requirments.txt`.
