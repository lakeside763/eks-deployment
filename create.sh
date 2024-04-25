# chmod -R u+x transactions-api
# 1. Create the kubernetes cluster
  # eksctl create cluster -f eksctl/cluster.yaml

# 2. Getting NodeGroup IAM Role from kubernetes cluster
  nodegroup_iam_role=$(aws eks describe-nodegroup --cluster-name school-mgt-eks  --nodegroup-name school-mgt-eks-node-group --query nodegroup.nodeRole --output text | xargs | cut -d "/" -f 2)


# 3. Installing Load Balancer Controller
  ( cd ./load-balancer-controller && ./create.sh )
  aws_lb_controller_policy=$(aws cloudformation describe-stacks --stack-name aws-load-balancer-iam-policy --query "Stacks[*].Outputs[?OutputKey=='IamPolicyArn'].OutputValue" --output text | xargs)
  aws iam attach-role-policy --role-name ${nodegroup_iam_role} --policy-arn ${aws_lb_controller_policy}

# 4. Create SSL Certificate in ACM
  ( cd ./ssl-certificate && ./create.sh)

# 5. Installing ExternalDNS
  ( cd ./external-dns && ./create.sh)
  aws iam attach-role-policy --role-name ${nodegroup_iam_role} --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess

# Deploy resources
kubectl apply -f manifests/resouces-ssl.yaml

echo "**********deployment**********"
kubeclt get deployments -n development
echo "******************************"

echo "**********deployment**********"
kubeclt get services -n development
echo "******************************"

echo "**********deployment**********"
kubeclt get pods -n kube-system
echo "******************************"