pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        S3_BUCKET = 'bucket-name'
        EC2_INSTANCE_ID = 'i-09d6850b97fe35d6e'
    }

    stages {
        stage('Build') {
            steps {
                script {
                    // Build Docker image and push to Docker Hub syedsdocker
                    sh 'docker build -t opensupports:latest .'
                    sh 'docker tag opensupports:latest opensupports/opensupports:latest'
                    sh 'docker push opensupports/opensupports:latest'
                }
            }
        }
        
        stage('Deploy to Development') {
            steps {
                script {
                    // Deploy to Development Terraform to deploy
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    // Run any tests or validations here (example: hit the app's API or check logs)
                    sh 'curl -I http://18.206.223.137'
                }
            }
        }

        stage('Deploy to Staging') {
            steps {
                script {
                    
                    sh 'terraform apply -auto-approve -var="env=staging"'
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                script {
                    // Deploy to Production
                    sh 'terraform apply -auto-approve -var="env=production"'
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
        }
    }
}
