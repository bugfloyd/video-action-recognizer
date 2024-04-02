#!/bin/bash
set -e

# Specify AWS profile
AWS_PROFILE=${1:-default}

# Generate RSA Key
PRIVATE_KEY=$(openssl genrsa 2048)

# Extract Public Key from Private Key
PUBLIC_KEY=$(openssl rsa -pubout -in <(echo "$PRIVATE_KEY"))

# Store key pair
aws secretsmanager update-secret \
  --secret-id "cloudfront_signing_private_key" \
  --secret-string "$PRIVATE_KEY" \
  --profile "${AWS_PROFILE}" \
  --no-cli-pager

aws secretsmanager update-secret \
  --secret-id "cloudfront_signing_key_id" \
  --secret-string "$PUBLIC_KEY" \
  --profile "${AWS_PROFILE}" \
  --no-cli-pager