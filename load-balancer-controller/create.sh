helm repo add eks https://aws.github.io/eks-charts

helm upgrade --install \
  --namespace kube-system \
  --create-namespace \
  --set clusterName=sample-eks \
  --set serviceAccount.create=true \
  aws-load-balancer-controller eks/aws-load-balancer-controller

aws cloudformation deploy \
  --stack-name aws-load-balancer-iam-policy \
  --template-file iam-policy.yaml \
  --capabilities CAPABILITY_IAM