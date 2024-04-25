# Getting NodeGroup IAM Role from kubernetes cluster
nodegroup_iam_role=$(aws eks describe-nodegroup --cluster-name sample-eks  --nodegroup-name sample-eks-node-group --query nodegroup.nodeRole --output text | xargs | cut -d "/" -f 2)

helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/
helm upgrade --install external-dns external-dns/external-dns --namespace kube-system

aws iam attach-role-policy --role-name ${nodegroup_iam_role} --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess

