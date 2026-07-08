#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-ap-south-1}"
REPOS=(
  "magento-sample-php-fpm"
  "magento-sample-nginx"
  "magento-sample-cron"
)

for repo in "${REPOS[@]}"; do
  echo "Checking ECR repository: $repo"
  aws ecr describe-repositories \
    --repository-names "$repo" \
    --region "$AWS_REGION" >/dev/null 2>&1 || \
  aws ecr create-repository \
    --repository-name "$repo" \
    --image-scanning-configuration scanOnPush=true \
    --region "$AWS_REGION"
done

echo "ECR repositories are ready."
