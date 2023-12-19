#!/bin/bash
CLUSTER_NAME="ml-gke"

# Install upstream Kueue
VERSION=v0.5.1
kubectl apply --server-side -f https://github.com/kubernetes-sigs/kueue/releases/download/$VERSION/manifests.yaml

gcloud container node-pools create nvidia-t4-reserved --cluster $CLUSTER_NAME \
  --machine-type n1-standard-2 \
  --shielded-secure-boot \
  --shielded-integrity-monitoring \
  --location=us-central1 \
  --accelerator type=nvidia-tesla-t4,count=1,gpu-driver-version=latest \
  --num-nodes=1 \
  --node-labels=tier=reserved

gcloud beta container node-pools create nvidia-t4-ondemand --cluster $CLUSTER_NAME \
  --machine-type n1-standard-2 \
  --shielded-secure-boot \
  --shielded-integrity-monitoring \
  --location us-central1 \
  --accelerator type=nvidia-tesla-t4,count=1,gpu-driver-version=latest \
  --num-nodes=0 --min-nodes=0 --max-nodes=3 \
  --enable-autoscaling \
  --node-labels=tier=ondemand 

gcloud beta container node-pools create nvidia-t4-queued --cluster $CLUSTER_NAME \
  --machine-type n1-standard-2 \
  --shielded-secure-boot \
  --shielded-integrity-monitoring \
  --location us-central1 \
  --accelerator type=nvidia-tesla-t4,count=1,gpu-driver-version=latest \
  --num-nodes=0 --min-nodes=0 --max-nodes=3 \
  --enable-autoscaling \
  --enable-queued-provisioning --no-enable-autorepair --no-enable-autoupgrade --reservation-affinity=none \
  --node-labels=tier=queued
