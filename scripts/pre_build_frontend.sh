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

  # Get the full path to sentry-cli
  SENTRY_CLI_PATH="$(yarn global bin)/sentry-cli"

  echo "Required environment variables:"
  echo "AWS_COMMIT_ID: ${AWS_COMMIT_ID}"
  echo "REACT_APP_SENTRY_RELEASE: ${REACT_APP_SENTRY_RELEASE}"
  echo "REACT_APP_ENVIRONMENT: ${REACT_APP_ENVIRONMENT}"
  echo "REACT_APP_SENTRY_ORG: ${REACT_APP_SENTRY_ORG}"
  echo "REACT_APP_SENTRY_PROJECT: ${REACT_APP_SENTRY_PROJECT}"

  echo "Optional environment variables:"
  echo "REACT_APP_SENTRY_DEBUG: ${REACT_APP_SENTRY_DEBUG}"
  echo "REACT_APP_SENTRY_NORMALIZE_DEPTH: ${REACT_APP_SENTRY_NORMALIZE_DEPTH}"
  echo "REACT_APP_SENTRY_TRACES_SAMPLE_RATE: ${REACT_APP_SENTRY_TRACES_SAMPLE_RATE}"
  echo "REACT_APP_SENTRY_REPLAYS_SESSION_SAMPLE_RATE: ${REACT_APP_SENTRY_REPLAYS_SESSION_SAMPLE_RATE}"
  echo "REACT_APP_SENTRY_REPLAYS_ON_ERROR_SAMPLE_RATE: ${REACT_APP_SENTRY_REPLAYS_ON_ERROR_SAMPLE_RATE}"

  # Get proposed release version from sentry-cli
  REACT_APP_SENTRY_RELEASE=$($SENTRY_CLI_PATH releases propose-version -o ${REACT_APP_SENTRY_ORG} -p ${REACT_APP_SENTRY_PROJECT})
  export REACT_APP_SENTRY_RELEASE

  # Check required environment variables
  required_vars="AWS_COMMIT_ID REACT_APP_SENTRY_RELEASE REACT_APP_ENVIRONMENT REACT_APP_SENTRY_ORG REACT_APP_SENTRY_PROJECT"
  for var in $required_vars; do
    if [ -z "${!var}" ]; then
      echo "Error: $var is not set" >&2
      return 1
    fi
  done

  # Create a new release on Sentry
  echo "Creating a new release on Sentry..."
  $SENTRY_CLI_PATH releases new -o ${REACT_APP_SENTRY_ORG} -p ${REACT_APP_SENTRY_PROJECT} ${REACT_APP_SENTRY_RELEASE}
  # Associate commits with the release
  echo "Associating commits with the release..."
  $SENTRY_CLI_PATH releases set-commits --auto ${REACT_APP_SENTRY_RELEASE}
  # Finalize the release
  echo "Finalizing the release..."
  $SENTRY_CLI_PATH releases finalize ${REACT_APP_SENTRY_RELEASE}

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