# Dockerfile for Strapi Application
# Created by: Arman Bisht

# Use Node.js LTS version
FROM node:20-alpine

# Install yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /app

# Copy root package files first
COPY ../../package*.json ../../yarn.lock ./
COPY ../../.yarnrc.yml ./

# Copy workspace packages
COPY ../../packages ./packages

# Copy the example app
COPY . ./examples/getstarted

# Install dependencies from root
RUN yarn install

# Set working directory to example app
WORKDIR /app/examples/getstarted

# Expose Strapi port
EXPOSE 1337

# Set environment to development (for easier setup)
ENV NODE_ENV=development

# Start the application
CMD ["yarn", "develop"]
