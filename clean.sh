#!/bin/bash

echo "Start netoyage"

# Infra clean
terraform destroy -auto-approve

# Delete files
echo "Remove temp files..."
rm -f .env.*

echo "Everything is clean!"