#!/bin/bash

# Initialize variables for optional parameters
AWS_PROFILE=""
AWS_REGION=""

# Initialize variables for required parameters with empty defaults
USER_POOL_ID=""
EMAIL=""
GIVEN_NAME=""
FAMILY_NAME=""
PASSWORD=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --user-pool-id)
      USER_POOL_ID="$2"
      shift # past argument
      shift # past value
      ;;
    --email)
      EMAIL="$2"
      shift # past argument
      shift # past value
      ;;
    --given-name)
      GIVEN_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    --family-name)
      FAMILY_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    --password)
      PASSWORD="$2"
      shift # past argument
      shift # past value
      ;;
    --profile)
      AWS_PROFILE="--profile $2"
      shift # past argument
      shift # past value
      ;;
    --region)
      AWS_REGION="--region $2"
      shift # past argument
      shift # past value
      ;;
    *)
      shift # past argument
      ;;
  esac
done

# Check for required parameters
if [[ -z "$USER_POOL_ID" || -z "$EMAIL" || -z "$GIVEN_NAME" || -z "$FAMILY_NAME" || -z "$PASSWORD" ]]; then
  echo "Error: Missing required parameters."
  echo "Usage: $0 --user-pool-id <value> --email <value> --given-name <value> --family-name <value> --password <value> [--profile <name>] [--region <value>]"
  exit 1
fi

# AWS Cognito command to create a new user in the user pool
aws cognito-idp admin-create-user \
  --user-pool-id "$USER_POOL_ID" \
  --username "$EMAIL" \
  --user-attributes \
    Name=email,Value="$EMAIL" \
    Name=email_verified,Value=true \
    Name=given_name,Value="$GIVEN_NAME" \
    Name=family_name,Value="$FAMILY_NAME" \
  --message-action SUPPRESS \
  $AWS_PROFILE $AWS_REGION > /dev/null

# Check if the previous command was successful
if [ $? -eq 0 ]; then
  echo "User created successfully."

  # AWS Cognito command to set a new user's password
  aws cognito-idp admin-set-user-password \
    --user-pool-id "$USER_POOL_ID" \
    --username "$EMAIL" \
    --password "$PASSWORD" \
    --permanent \
    $AWS_PROFILE $AWS_REGION > /dev/null

  if [ $? -eq 0 ]; then
    echo "Password set successfully."
  else
    echo "Failed to set password."
  fi
else
  echo "Failed to create user."
fi