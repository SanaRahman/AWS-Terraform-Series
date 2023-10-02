
# Use the official Node.js image as the base image
FROM node:16-alpine
# Set the working directory inside the container
WORKDIR /app
# Copy the package.json and package-lock.json files to the container
COPY package.json package-lock.json ./
# Install dependencies
RUN npm install
# Copy the rest of the application files to the container
COPY . .
# Build the React app
RUN npm run build
# Use the 'serve' package to serve the built React app
RUN npm install -g serve
# Expose the port on which the app will run inside the container
EXPOSE 3000
# Start the app using the 'serve' command
CMD ["serve", "-s", "build"]
