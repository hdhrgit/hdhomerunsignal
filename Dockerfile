# Multi-stage build for React frontend and Node.js backend
FROM node:24-alpine AS frontend-build

WORKDIR /app/frontend
COPY frontend/package.json ./
RUN npm install

COPY frontend/ ./
RUN npm run build

# Backend stage
FROM ubuntu:22.04

# Install Node.js and libhdhomerun from apt
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    hdhomerun-config \
    libhdhomerun-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs

WORKDIR /app

# Copy backend dependencies
COPY backend/package.json ./
RUN npm install --only=production

# Copy backend source
COPY backend/ ./

# Copy built frontend
COPY --from=frontend-build /app/frontend/build ./public

EXPOSE 3000

CMD ["node", "server.js"]
