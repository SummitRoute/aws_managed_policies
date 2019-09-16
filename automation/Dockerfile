FROM woahbase/alpine-awscli:x86_64

# Prepare the container
RUN apk update && apk add \
    git \
    jq

# temp credentials (outside AWS IAM Role)
ENV AWS_REGION=eu-west-1
ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=
ENV AWS_SESSION_TOKEN=
ENV AWS_SECURITY_TOKEN=

WORKDIR /app

# Handle the bash job
COPY script-fargate.sh /app/script.sh
RUN chmod +x /app/script.sh

CMD ["bash", "script.sh"]