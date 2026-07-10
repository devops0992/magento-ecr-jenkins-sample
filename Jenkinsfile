pipeline {
    agent any

    environment {
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
