# Multi-stage build for React frontend
FROM node:18-alpine as build

# Set working directory
WORKDIR /app

# Install dependencies for native modules
RUN apk add --no-cache python3 make g++

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm install --legacy-peer-deps && npm cache clean --force

# Copy source code
COPY . .

# Clear npm cache and reinstall if needed
RUN npm cache clean --force

# Build the application
RUN NODE_OPTIONS="--openssl-legacy-provider" npm run build

# Verify build was successful
RUN ls -la build/ || (echo "Build failed - no build directory found" && exit 1)

# Production stage with nginx
FROM nginx:alpine

# Copy built application from build stage
COPY --from=build /app/build /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
