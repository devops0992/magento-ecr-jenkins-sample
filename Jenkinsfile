def images = [
    [repo: 'magento-sample-php-fpm', dockerfile: 'Dockerfile', context: '.'],
    [repo: 'magento-sample-nginx',   dockerfile: 'docker/nginx/Dockerfile', context: '.'],
    [repo: 'magento-sample-cron',    dockerfile: 'docker/cron/Dockerfile', context: '.']
]

pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        AWS_REGION = 'ap-south-1'
        DOCKER_BUILDKIT = '1'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Step 1: Pulling source code from Git repository...'
                checkout scm
            }
        }

        stage('Prepare Tag') {
            steps {
                script {
                    env.GIT_SHORT_SHA = sh(script: 'git rev-parse --short=8 HEAD', returnStdout: true).trim()
                    env.IMAGE_TAG = "build-${env.BUILD_NUMBER}-${env.GIT_SHORT_SHA}"
                    env.AWS_ACCOUNT_ID = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
                    env.ECR_REGISTRY = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_REGION}.amazonaws.com"

                    echo "Step 2: Unique image tag created: ${env.IMAGE_TAG}"
                    echo "ECR registry: ${env.ECR_REGISTRY}"
                }
            }
        }

        stage('Validate Files') {
            steps {
                echo 'Step 3: Checking required Dockerfiles...'
                sh '''
                  test -f Dockerfile
                  test -f docker/nginx/Dockerfile
                  test -f docker/cron/Dockerfile
                  test -f docker-compose.yml
                '''
                echo 'Validation completed.'
            }
        }

        stage('Login to ECR') {
            steps {
                echo 'Step 4: Logging in to AWS ECR...'
                sh '''
                  aws ecr get-login-password --region $AWS_REGION \
                  | docker login --username AWS --password-stdin $ECR_REGISTRY
                '''
            }
        }

        stage('Create ECR Repos') {
            steps {
                script {
                    echo 'Step 5: Creating ECR repositories if they do not exist...'
                    images.each { img ->
                        sh """
                          aws ecr describe-repositories \
                            --repository-names ${img.repo} \
                            --region ${AWS_REGION} >/dev/null 2>&1 || \
                          aws ecr create-repository \
                            --repository-name ${img.repo} \
                            --image-scanning-configuration scanOnPush=true \
                            --region ${AWS_REGION}
                        """
                    }
                }
            }
        }

        stage('Build Images') {
            steps {
                script {
                    echo 'Step 6: Building Docker images...'
                    images.each { img ->
                        sh """
                          docker build \
                            -f ${img.dockerfile} \
                            -t ${img.repo}:${IMAGE_TAG} \
                            ${img.context}

                          docker tag ${img.repo}:${IMAGE_TAG} \
                            ${ECR_REGISTRY}/${img.repo}:${IMAGE_TAG}
                        """
                    }
                }
            }
        }

        stage('Push Images') {
            steps {
                script {
                    echo 'Step 7: Pushing Docker images to ECR...'
                    sh 'rm -f image-tags.txt'

                    images.each { img ->
                        sh """
                          docker push ${ECR_REGISTRY}/${img.repo}:${IMAGE_TAG}
                          echo ${ECR_REGISTRY}/${img.repo}:${IMAGE_TAG} >> image-tags.txt
                        """
                    }
                }
            }
        }

        stage('Show Output') {
            steps {
                echo 'Step 8: Final pushed image URLs:'
                sh 'cat image-tags.txt'
                archiveArtifacts artifacts: 'image-tags.txt', fingerprint: true
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: All custom Magento sample images were pushed to ECR.'
        }
        failure {
            echo 'FAILED: Check Docker, AWS CLI, IAM role, or ECR permissions.'
        }
        always {
            echo 'Cleaning unused Docker images on Jenkins node...'
            sh 'docker image prune -f || true'
        }
    }
}
