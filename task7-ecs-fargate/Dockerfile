# Dockerfile for Strapi on ECS Fargate
FROM node:18-alpine

WORKDIR /opt/app

# Install dependencies for Strapi
RUN apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    vips-dev \
    git

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install --production=false

# Copy application files
COPY . .

# Set environment to development (more forgiving for first run)
ENV NODE_ENV=development

# Expose Strapi port
EXPOSE 1337

# Start Strapi in development mode (auto-builds on first run)
CMD ["npm", "run", "develop"]
