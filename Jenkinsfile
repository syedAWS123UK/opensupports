pipeline {
  agent any
  stages {
    stage('Clone Repository') {
      steps {
        git 'https://github.com/syedAWS123UK/opensupports.git'
      }
    }
    stage('Terraform Plan') {
      steps {
        sh 'cd terraform && terraform plan'
      }
    }
    stage('Terraform Apply') {
      steps {
        sh 'cd terraform && terraform apply -auto-approve'
      }
    }
    stage('Deploy Application') {
      steps {
        sh '''
        ssh -o StrictHostKeyChecking=no -i /path/to/key.pem ubuntu@ip-172-31-80-35 << EOF
        cd /var/www/
        docker-compose up -d
        EOF
        '''
      }
    }
  }
}
