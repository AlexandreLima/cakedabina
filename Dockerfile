# Multi-stage build for Cake da Bina website
# Stage 1: Build stage (optional for asset optimization)
FROM node:20-alpine AS builder

WORKDIR /app

# Copy source files
COPY index.html styles.css script.js ./
COPY nginx.conf /tmp/nginx.conf
COPY images/ ./images/
COPY assets/ ./assets/

# Optional: Install asset optimization tools
RUN apk add --no-cache imagemagick

# Verify files exist
RUN ls -la && echo "✓ All source files present"

# Stage 2: Runtime stage (nginx)
FROM nginx:1.27-alpine

# Set labels for metadata
LABEL maintainer="Alexandre <xandebre@gmail.com>"
LABEL description="Cake da Bina - Bakery website"
LABEL version="1.0"

# Install health check dependencies
RUN apk add --no-cache curl

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy website files from builder or local
COPY --from=builder /app/index.html /usr/share/nginx/html/
COPY --from=builder /app/styles.css /usr/share/nginx/html/
COPY --from=builder /app/script.js /usr/share/nginx/html/
COPY images/ /usr/share/nginx/html/images/
COPY assets/ /usr/share/nginx/html/assets/
COPY site.webmanifest /usr/share/nginx/html/
COPY sitemap.xml /usr/share/nginx/html/
COPY robots.txt /usr/share/nginx/html/
COPY .htaccess /usr/share/nginx/html/ 2>/dev/null || true

# Set permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Create health endpoint handler in nginx
RUN echo "server { listen 80; location /health { return 200 'OK'; } }" | \
    tee /etc/nginx/conf.d/health.conf > /dev/null

# Expose port
EXPOSE 80

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
