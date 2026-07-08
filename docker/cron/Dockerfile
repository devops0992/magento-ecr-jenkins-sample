# Custom Cron image for Magento scheduled jobs
FROM alpine:3.20

RUN apk add --no-cache bash php82 php82-cli curl

COPY docker/cron/crontab /etc/crontabs/root
COPY scripts/cron-task.sh /usr/local/bin/cron-task.sh

RUN chmod +x /usr/local/bin/cron-task.sh

CMD ["crond", "-f", "-l", "8"]
