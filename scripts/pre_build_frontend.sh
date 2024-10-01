#!/bin/sh

# Exit immediately if a command exits with a non-zero status
set -e

# Treat unset variables as empty strings
set +u

# Enable debug mode
set -x

# Function definitions
pre_build() {
  # Install sentry-cli
  echo "Installing sentry-cli..."
  yarn global add @sentry/cli

  echo "Required environment variables:"
  echo "REACT_APP_SENTRY_ORG: ${REACT_APP_SENTRY_ORG}"

  return 0
}

# Main script execution
echo "Starting script..."

# Call functions or add script logic here
if pre_build; then
  echo "Pre-build process completed successfully."
  exit 0
else
  echo "Error: Pre-build process failed." >&2
  exit 1
fi