#!/bin/bash

SERVICE_NAME=$1

# Valid services
VALID_SERVICES=("orders" "payments" "inventory")

# Check service name
if [ -z "$SERVICE_NAME" ]; then
    echo "Error: No service name provided."
    echo "Usage: ./replace-app.sh <service-name>"
    exit 1
fi

# Validate
IS_VALID=false
for s in "${VALID_SERVICES[@]}"; do
    if [ "$s" == "$SERVICE_NAME" ]; then
        IS_VALID=true
        break
    fi
done

if [ "$IS_VALID" = false ]; then
    echo "Error: Service '$SERVICE_NAME' is not valid."
    echo "Allowed services: ${VALID_SERVICES[*]}"
    exit 1
fi

echo "Starting deployment for: $SERVICE_NAME"

# Run terraform apply for specific service
terraform apply \
    -replace="docker_container.apps[\"$SERVICE_NAME\"]" \
    -target="docker_container.apps[\"$SERVICE_NAME\"]" \
    -target="docker_image.apps_img[\"$SERVICE_NAME\"]" \
    -auto-approve

# Final check
if [ $? -eq 0 ]; then
    echo "Success: '$SERVICE_NAME' has been redeployed."
else
    echo "Failure: Terraform encountered an error."
    exit 1
fi