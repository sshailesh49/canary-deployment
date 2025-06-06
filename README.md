# canary-deployment
# ✅ Step 1: Enable IAM OIDC Provider for your EKS cluster
  expoet AWS_PROFILE=ram                  # aws profile name
  eksctl utils associate-iam-oidc-provider \
  --cluster CLUSTER_NAME \
  --region us-west-2
  --approve
 
# ✅ Step 2: Create IAM Policy for ALB Controller

  curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json

  aws iam create-policy \
      --policy-name AWSLoadBalancerControllerIAMPolicy \
      --region us-west-2
      --policy-document file://iam-policy.json

  # ✅ Step 3: Create IAM Role for ServiceAccount (IRSA)

    eksctl create iamserviceaccount \
          --cluster $CLUSTER_NAME \
          --namespace kube-system \
          --region us-west-2 \
          --name aws-load-balancer-controller \
          --attach-policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/AWSLoadBalancerControllerIAMPolicy \
         --approve

  # ✅ cert-manager Install with kubectl (v1.14.4)
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml

  # ✅ Step 4: Install AWS Load Balancer Controller using Helm
  #  Add Helm repo & update:
       helm repo add eks https://aws.github.io/eks-charts
       helm repo update

  # 🔹 Install the controller:
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=<your-cluster-name> \
    --set serviceAccount.create=false \
    --set region=<your-region> \
    --set vpcId=<your-vpc-id> \
    --set serviceAccount.name=aws-load-balancer-controller

# OP Upgrade the controller:
     helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
         -n kube-system \
         --set clusterName=$CLUSTER_NAME \
         --set serviceAccount.create=false \
         --set serviceAccount.name=aws-load-balancer-controller \
         --set region=$REGION \
         --set vpcId=<VPC_ID> \
        --set image.tag="v2.7.1"

# ✅ Step 5: Validate Controller is Running
   kubectl get deployment -n kube-system aws-load-balancer-controller


  



