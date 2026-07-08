# Magento ECR Jenkins Sample Project

This is a simple practice project for this flow:

```text
GitHub Repo → Jenkins Pipeline → Docker Build → AWS ECR Push
```

It is not a full Magento source code package. It is a lightweight Magento-style Docker Compose project that helps you build the Jenkins + ECR pipeline from scratch.

## Services

| Service | Image Type | Pushed to ECR? |
|---|---|---|
| nginx | Custom | Yes |
| php-fpm | Custom | Yes |
| cron | Custom | Yes |
| mysql | Public image | No |
| redis | Public image | No |

## Project Structure

```text
.
├── Jenkinsfile
├── Dockerfile
├── docker-compose.yml
├── public/index.php
├── docker/nginx/Dockerfile
├── docker/nginx/default.conf
├── docker/cron/Dockerfile
├── docker/cron/crontab
├── scripts/create-ecr-repos.sh
├── scripts/cron-task.sh
└── docs/ecr-iam-policy.json
```

## Test Locally

```bash
docker compose up --build -d
```

Open:

```text
http://localhost:8080
```

Stop:

```bash
docker compose down
```

## Jenkins Server Requirements

Install these on Jenkins EC2:

```bash
sudo apt update
sudo apt install -y docker.io awscli git
sudo usermod -aG docker jenkins
sudo systemctl restart docker
sudo systemctl restart jenkins
```

Attach an IAM role to the Jenkins EC2 instance using the policy in:

```text
docs/ecr-iam-policy.json
```

## Create ECR Repositories Manually

```bash
export AWS_REGION=ap-south-1
bash scripts/create-ecr-repos.sh
```

The Jenkinsfile also creates repositories automatically if missing.

## Jenkins Job Setup

1. Push this project to GitHub.
2. Open Jenkins.
3. Create a new Pipeline job.
4. Select Pipeline script from SCM.
5. Add your GitHub repository URL.
6. Set script path as:

```text
Jenkinsfile
```

7. Click Build Now.

## Output

After successful build, Jenkins will push images like:

```text
123456789012.dkr.ecr.ap-south-1.amazonaws.com/magento-sample-php-fpm:build-10-a1b2c3d4
123456789012.dkr.ecr.ap-south-1.amazonaws.com/magento-sample-nginx:build-10-a1b2c3d4
123456789012.dkr.ecr.ap-south-1.amazonaws.com/magento-sample-cron:build-10-a1b2c3d4
```

## How to Use This With Your Real Magento Project

After this sample pipeline works:

1. Replace `public/` and `app/` with your real Magento code.
2. Add required PHP extensions in the root `Dockerfile`.
3. Replace Nginx config with your Magento Nginx config.
4. Keep the Jenkinsfile structure the same.
5. Update repository names if required.

## Important

Do not commit these files:

```text
.terraform/
*.pem
*.key
certs/*.key
var/cache/
var/log/
```

They are already added in `.dockerignore` and `.gitignore`.
