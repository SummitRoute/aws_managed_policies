FROM woahbase/alpine-awscli:x86_64

# Prepare the container
RUN apk update && apk add \
    git \
    jq \
    python3

ENV AWS_REGION=eu-west-1

WORKDIR /app

COPY requirements.txt /app/
RUN python3 -m pip install -r /app/requirements.txt
COPY validate.py /app/
COPY script-fargate.sh /app/script.sh
RUN chmod +x /app/script.sh

CMD ["bash", "script.sh"]
