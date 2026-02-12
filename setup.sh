#!/bin/bash

echo "Starting setup..."

WORKSPACE=$(terraform workspace show)
echo "Workspace: $WORKSPACE"

terraform apply -refresh=false -auto-approve -compact-warnings

if [ $? -eq 0 ]; then
    echo "Ready!"
    
    echo "Env files updated"
else
    echo "Error infra, check docker and pods."
    exit 1
fi