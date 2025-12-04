# Dockerfile for Strapi Application
# Created by: Arman Bisht

# Use Node.js LTS version
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package files and yarn configuration
COPY package*.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

# Copy all necessary files
COPY packages ./packages
COPY examples ./examples

# Install dependencies
RUN yarn install

# Set working directory to example app
WORKDIR /app/examples/getstarted

# Expose Strapi port
EXPOSE 1337

# Set environment
ENV NODE_ENV=development

# Start the application
CMD ["npm", "run", "develop"]
