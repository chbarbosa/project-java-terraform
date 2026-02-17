#!/bin/bash

set -e

echo "Start building..."

servicos=("orders" "payments" "inventory")

for s in "${servicos[@]}"
do
    echo "Service building: $s"
    
    cd "$s-service"
    mvn clean package -DskipTests
    
    docker build -t "projeto/$s:latest" .
    
    cd ..
done

echo "Builds finished"
