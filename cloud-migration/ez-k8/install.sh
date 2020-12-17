#!/bin/sh

echo "Creating easyTravel"
kubectl create -f config.yaml

echo "Waiting for 150 seconds before starting loadgen"
sleep 150

echo "Creating load generator"
kubectl create -f loadgen.yaml