# Dockerfile for Strapi on ECS Fargate
FROM node:18-alpine

WORKDIR /opt/app

# Install dependencies
RUN apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev vips-dev git

# Copy package files
COPY package*.json ./

# Install all dependencies
RUN npm install

# Copy application code
COPY . .

# Create required directories
RUN mkdir -p public/uploads .tmp

# Build Strapi admin
ENV NODE_ENV=production
RUN npm run build

# Expose port
EXPOSE 1337

# Start Strapi
CMD ["npm", "run", "start"]
