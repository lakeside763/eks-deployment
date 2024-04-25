#!/bin/bash

# Get the account ID (alternative using jq)
# account_id=$(aws sts get-caller-identity | jq -r '.Account')

# Get the account ID (using grep and awk)
account_id=$(aws sts get-caller-identity | grep Account | awk '{print $2}')

# Getting NodeGroup IAM Role from kubernetes cluster
nodegroup_iam_role=$(aws eks describe-nodegroup --cluster-name sample-eks  --nodegroup-name sample-eks-node-group --query nodegroup.nodeRole --output text | xargs | cut -d "/" -f 2)


# Create the IAM policy
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json

# Create the EKS service account (using eksctl)
eksctl create iamserviceaccount \
  --cluster=my-sample-eks \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::"${account_id}":policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

# (Optional) Verify Helm installation
# helm version

# Add the EKS Helm repository (assuming not already added)
helm repo add eks https://aws.github.io/eks-charts

# Update the repository (recommended before installing)
helm repo update eks

# Install the AWS Load Balancer Controller using Helm
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=sample-eks

# (Optional) Search for available versions (useful for upgrades)
# helm search repo eks/aws-load-balancer-controller --versions

# Verify the ALB Controller deployment
kubectl get deployment -n kube-system aws-load-balancer-controller

# Attach loadbalancer policy to eks nodegroup
aws iam attach-role-policy --role-name ${nodegroup_iam_role} --policy-arn ${aws_lb_controller_policy}