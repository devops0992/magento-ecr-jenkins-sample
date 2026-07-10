pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        timestamps()
    }

    environment {
        REPO_URL       = 'https://github.com/devops0992/magento-ecr-jenkins-sample.git'

        AWS_REGION     = 'ap-south-1'
        AWS_ACCOUNT_ID = '471613013689'

        ECR_REGISTRY   = '471613013689.dkr.ecr.ap-south-1.amazonaws.com'
        ECR_REPOSITORY = 'dev/magento'
        ECR_IMAGE      = '471613013689.dkr.ecr.ap-south-1.amazonaws.com/dev/magento'

        LOCAL_IMAGE    = 'magento-sample'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                echo 'Pulling source code from GitHub...'

                git branch: 'main',
                    url: "${env.REPO_URL}"

                sh '''
                    echo "Current Git commit:"
                    git rev-parse --short=8 HEAD

                    echo "Repository files:"
                    ls -la
                '''
            }
        }

        stage('Generate Image Tag') {
            steps {
                script {
                    env.SHORT_COMMIT = sh(
                        script: 'git rev-parse --short=8 HEAD',
                        returnStdout: true
                    ).trim()

                    env.IMAGE_TAG = "${env.BUILD_NUMBER}-${env.SHORT_COMMIT}"
                }

                echo "Generated image tag: ${env.IMAGE_TAG}"
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

        stage('Check Docker') {
            steps {
                echo 'Checking Docker installation...'

                sh '''
                    docker --version
                    docker info > /dev/null
                    echo "Docker is accessible."
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${env.LOCAL_IMAGE}:${env.IMAGE_TAG}"

                sh '''
                    docker build \
                        --tag ${LOCAL_IMAGE}:${IMAGE_TAG} \
                        .
                '''
            }
        }

        stage('Login to Amazon ECR') {
            steps {
                echo "Logging in to ECR registry: ${env.ECR_REGISTRY}"

                sh '''
                    aws ecr get-login-password \
                        --region ${AWS_REGION} |
                    docker login \
                        --username AWS \
                        --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Tag Image for ECR') {
            steps {
                echo "Tagging image as ${env.ECR_IMAGE}:${env.IMAGE_TAG}"

                sh '''
                    docker tag \
                        ${LOCAL_IMAGE}:${IMAGE_TAG} \
                        ${ECR_IMAGE}:${IMAGE_TAG}
                '''
            }
        }

        stage('Push Image to Amazon ECR') {
            steps {
                echo "Pushing image: ${env.ECR_IMAGE}:${env.IMAGE_TAG}"

                sh '''
                    docker push ${ECR_IMAGE}:${IMAGE_TAG}
                '''
            }
        }

        stage('Verify Image in Amazon ECR') {
            steps {
                echo "Verifying image tag: ${env.IMAGE_TAG}"

                sh '''
                    aws ecr describe-images \
                        --repository-name ${ECR_REPOSITORY} \
                        --image-ids imageTag=${IMAGE_TAG} \
                        --region ${AWS_REGION} \
                        --query 'imageDetails[0].{Tag:imageTags[0],Digest:imageDigest,Size:imageSizeInBytes}' \
                        --output table
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
            echo "Image pushed: ${env.ECR_IMAGE}:${env.IMAGE_TAG}"
        }

        failure {
            echo 'Pipeline failed. Check the failed stage in Console Output.'
        }

        always {
            echo "Jenkins build number: ${env.BUILD_NUMBER}"

            sh '''
                docker logout ${ECR_REGISTRY} || true
            '''
        }
    }
}
