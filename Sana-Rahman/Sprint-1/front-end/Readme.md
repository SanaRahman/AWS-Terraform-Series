
# API CALLER APPLICATION

## Project Description
"RETS-API" is an application's frontend built using React, designed to provide users with a user-friendly interface to configure and initiate RESTful API calls. The application allows users to set three essential parameters:

RESTful Public API Endpoint: Users can specify the URL of a public API endpoint, such as https://www.boredapi.com/api/activity, from which they wish to retrieve data.

1. Frequency of API Endpoint Calls: Users can set the desired frequency at which the API endpoint should be called, indicating the number of REST calls per hour.

2. Duration of API Calls: Users can define the duration for which the API calls should run, specifying the number of hours during which the calls will be made.

3. Once users have set these parameters, they can initiate the API calls through the application. The frontend then communicates with the backend to handle the API calls based on the configured frequency and duration. The backend retrieves the API responses and sends them back to the frontend for display.
All the code is present in rest-api folder

## Running the Frontend Locally

To run the frontend of the "API Caller: Fetch n' Store" project locally, follow these steps:

1. Make sure you have Node.js installed on your machine.
2. Clone or download the repository containing the frontend code.
3. Navigate to the frontend directory in your terminal.
4. Install the required dependencies by running the following command:
   ```bash
   npm install
   ```
5. Once the dependencies are installed, start the development server by running:
   ```bash
   npm start
   ```
6. The frontend application will now be accessible at http://localhost:3000 in your web browser.

## Dockerization

The frontend of the "API Caller: Fetch n' Store" project can also be containerized using Docker. A Dockerfile is provided in the root directory of the project, which automates the containerization process.

To run the frontend using Docker, follow these steps:

1. Ensure you have Docker installed on your system.
2. Clone or download the repository containing the frontend code.
3. Navigate to the root directory of the frontend project in your terminal.
4. Build the Docker image using the following command:
   ```bash
   docker build -t frontend-image.
   ```
5. After the image is built, run a Docker container based on the image with the following command:
   ```bash
   docker run -p 3000:3000 fontend-image
   ```
6. The frontend application will now be accessible at http://localhost:3000 in your web browser, just like when running locally.

## Dependencies

The frontend project relies on the following key dependencies:

- React: JavaScript library for building user interfaces.
- Node.js: JavaScript runtime to execute the frontend application.
- `create-react-app`: Tool used to set up a new React project with a modern build setup.

These dependencies are defined in the `package.json` file and are automatically installed when setting up the project using `npm install`.
