#!/bin/sh
kubectl apply -f metrics-server-1-8

# Verify that the metrics-server deployment is running the desired number of pods with the following command.
kubectl get deployment metrics-server -n kube-system

# Step 2: Deploy the Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta5/aio/deploy/recommended.yaml

## 
kubectl apply -f eks-admin-service-account.yaml