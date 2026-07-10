pipeline {
    agent any

    environment {
        REPO_URL            = 'https://github.com/devops0992/magento-ecr-jenkins-sample.git'
        AWS_REGION          = 'ap-south-1'

        ECR_REGISTRY        = '471613013689.dkr.ecr.ap-south-1.amazonaws.com'
        ECR_REPOSITORY      = 'dev/magento'
        ECR_IMAGE           = '471613013689.dkr.ecr.ap-south-1.amazonaws.com/dev/magento'
        IMAGE_NAME = 'magento-sample'
    }

    stages {
        stage('Checkout GitHub Repository') {
            steps {
                echo 'Cloning source code from GitHub...'

                checkout scm

                sh '''
                    echo "Current branch:"
                    git branch --show-current

                    echo "Current commit:"
                    git rev-parse --short HEAD

                    echo "Repository files:"
                    ls -la
                '''
            }
        }

        stage('Check Docker') {
            steps {
                echo 'Checking Docker installation...'

                sh '''
                    docker --version
                    docker info > /dev/null
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${IMAGE_NAME}:${BUILD_NUMBER}"

                sh '''
                    docker build \
                        --tag ${IMAGE_NAME}:${BUILD_NUMBER} \
                        .
                '''
            }
        }

        stage('Verify Docker Image') {
            steps {
                echo 'Verifying the generated Docker image...'

                sh '''
                    docker image inspect ${IMAGE_NAME}:${BUILD_NUMBER}

                    echo "Available application images:"
                    docker images ${IMAGE_NAME}
                '''
            }
        }

        stage('Verify AWS Connection') {
            steps {
                echo 'Verifying Jenkins connection to AWS...'

                sh '''
                    aws --version
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Push Image to Amazon ECR') {
            steps {
                echo "Pushing image: ${ECR_IMAGE}:${IMAGE_TAG}"

                sh '''
                    docker push ${ECR_IMAGE}:${IMAGE_TAG}
                '''
            }
        }

        stage('Verify Image in Amazon ECR') {
            steps {
                echo 'Verifying the pushed image in Amazon ECR...'

                sh '''
                    aws ecr describe-images \
                      --repository-name ${ECR_REPOSITORY} \
                      --image-ids imageTag=${IMAGE_TAG} \
                      --region ${AWS_REGION}
                '''
            }
        }
    }

    post {
        success {
            echo "Docker image successfully created:"
            echo "${IMAGE_NAME}:${BUILD_NUMBER}"
        }

        failure {
            echo 'Pipeline failed. Check the Jenkins console output.'
        }

        always {
            echo "Jenkins build number: ${BUILD_NUMBER}"
        }
    }
}
