FROM woahbase/alpine-awscli:x86_64

# Prepare the container
RUN apk update && apk add \
    git \
    jq

ENV AWS_REGION=eu-west-1

WORKDIR /app

# Handle the bash job
COPY script-fargate.sh /app/script.sh
RUN chmod +x /app/script.sh

CMD ["bash", "script.sh"]