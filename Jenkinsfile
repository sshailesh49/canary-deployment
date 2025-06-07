pipeline {
  agent any
  environment {
    // KUBECTL_VERSION = 'v1.30.0'
   //  KUBECONFIG = credentials('eks-kubeconfig-id')
    THRESHOLD = '5'
  }
  stages {
      stage('Checkout from Git') {
       steps {
        script {
          code_checkout('https://github.com/sshailesh49/canary-deployment.git', 'main', 'git-token')
        }
      }
    }
    stage('Deploy Canary') {
         steps {
          withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'shailesh-aws-id', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
             sh """
              aws eks update-kubeconfig --region us-west-2 --name my-eks-cluster
              kubectl apply -f manifests/
              kubectl get pods
              """
           }
          }
       }
    stage('Monitor Metrics') {
      steps {
        sh 'chmod +x scripts/monitor_metrics.sh'
        sh './scripts/monitor_metrics.sh $THRESHOLD'
      }
    }
    stage('Promote to 20%') {
      steps {
        withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'shailesh-aws-id', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        sh 'chmod +x scripts/update_ingress_weight.sh'
        sh './scripts/update_ingress_weight.sh app-v2 20'
        }
      }
    }
    stage('Monitor Metrics') {
      steps {
        sh 'chmod +x scripts/monitor_metrics.sh'
        sh './scripts/monitor_metrics.sh $THRESHOLD'
      }
    }
    stage('Promote to 50%') {
      steps {
        withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'shailesh-aws-id', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        sh './scripts/update_ingress_weight.sh app-v2 50'
        }
      }
    }
    stage('Monitor Metrics') {
      steps {
        sh 'chmod +x scripts/monitor_metrics.sh'
        sh './scripts/monitor_metrics.sh $THRESHOLD'
      }
    }
    stage('Promote to 100%') {
      steps {
        withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'shailesh-aws-id', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
        sh './scripts/update_ingress_weight.sh app-v2 100'
        }
      }
    }
      stage('Monitor Metrics') {
      steps {
        sh 'chmod +x scripts/monitor_metrics.sh'
        sh './scripts/monitor_metrics.sh $THRESHOLD'
      }
    }
  }
  post {
    failure {
      withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'shailesh-aws-id', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
      sh './scripts/update_ingress_weight.sh app-v2 0'
    }
    }
    
  }
}
