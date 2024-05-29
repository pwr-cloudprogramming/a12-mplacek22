# Use the official Nginx image from Docker Hub
FROM nginx:alpine

# Remove the default Nginx configuration and static files
RUN rm /etc/nginx/conf.d/default.conf
RUN rm -rf /usr/share/nginx/html/*

# Copy the static content from the 'src' directory into the container
COPY src/* /usr/share/nginx/html/

# Create a custom Nginx configuration file directly in the Dockerfile
RUN echo 'server { listen 3000; server_name localhost; location / { root /usr/share/nginx/html; index index.html; try_files $uri $uri/ =404; } }' > /etc/nginx/conf.d/default.conf

# Copy the start script into the container
COPY start.sh /start.sh

# Make the start script executable
RUN chmod +x /start.sh

# Expose port 3000 for the container
EXPOSE 3000

# Start Nginx when the container has provisioned.
CMD ["./start.sh"]
