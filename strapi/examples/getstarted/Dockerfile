# Dockerfile for Strapi Application with PostgreSQL
# Created by: Arman Bisht
# Task 3: Docker Network Setup

# Use Node.js LTS version
FROM node:20-alpine

# Install system dependencies for PostgreSQL and build tools
RUN apk add --no-cache postgresql-client python3 make g++

# Set working directory
WORKDIR /opt/strapi

# Copy root package files and yarn config
COPY ../../package*.json ../../yarn.lock ./
COPY ../../.yarnrc.yml ./
COPY ../../.yarn ./.yarn

# Copy workspace packages (needed for workspace: dependencies)
COPY ../../packages ./packages

# Copy examples folder structure
COPY ../../examples ./examples

# Install all dependencies from root
RUN yarn install

# Set working directory to the example app
WORKDIR /opt/strapi/examples/getstarted

# Create uploads directory
RUN mkdir -p public/uploads

# Expose Strapi port
EXPOSE 1337

# Set environment to development
ENV NODE_ENV=development

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD node -e "require('http').get('http://localhost:1337/_health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["yarn", "develop"]
