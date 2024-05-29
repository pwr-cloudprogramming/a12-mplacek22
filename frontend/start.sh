#!/bin/sh

# Check if ALB_DNS_NAME is set
if [ -z "$ALB_DNS_NAME" ]; then
  echo "Error: ALB_DNS_NAME environment variable is not set."
  exit 1
fi

# Check if COGNITO_USER_POOL_ID is set
if [ -z "$COGNITO_USER_POOL_ID" ]; then
  echo "Error: COGNITO_USER_POOL_ID environment variable is not set."
  exit 1
fi

# Check if COGNITO_CLIENT_ID is set
if [ -z "$COGNITO_CLIENT_ID" ]; then
  echo "Error: COGNITO_CLIENT_ID environment variable is not set."
  exit 1
fi

# Replace placeholders with the actual values in index.js and cognito.js
sed -i "s/<ALB_DNS_NAME>/${ALB_DNS_NAME}/g" /usr/share/nginx/html/index.js
sed -i "s/<COGNITO_USER_POOL_ID>/${COGNITO_USER_POOL_ID}/g" /usr/share/nginx/html/cognito.js
sed -i "s/<COGNITO_CLIENT_ID>/${COGNITO_CLIENT_ID}/g" /usr/share/nginx/html/cognito.js

# Start Nginx
nginx -g "daemon off;"
