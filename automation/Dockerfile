FROM woahbase/alpine-awscli:x86_64

# Prepare the container
RUN apk update && apk add \
    git \
    jq

# temp credentials (outside AWS IAM Role)
ENV AWS_REGION=eu-west-1
ENV AWS_ACCESS_KEY_ID=ASIAYIJX3R336BASDJEN
ENV AWS_SECRET_ACCESS_KEY=1hHzY4buwzdDB0mCxFEIFT9ToVCo7TlWHUKkSnrp
ENV AWS_SESSION_TOKEN=FQoGZXIvYXdzEKf//////////wEaDMlxx3VJhzbyUjbhByL7AXYW1JA9aljT3Fg+NC9GYP+hWFk10UW/iDqgDP0sB70b5ERaZxeyIrkKosXJDs08TGDc9Ofm1rT1YcadhDIAkNwL45xqwjxpWoW95bi6/vFHjVQ6VrUB0OijJMxvWuVWNzSQ/pp/tduSOc8Xj9IgnzfvEPLaf3f4LY51+PftCMa3tCdpPMLgcwLB7u4MFvVl5fT3GmBNXs5Bm1/QOxQUdi7dT6r9iibFyKZnLwffTDP0G0C35eqXwhtJOnV3DcZrlg0ZIKCStIyajWlBHrhE/pWx0QubttwZMjoTv9q/iAlXwlAt5N6QI+WJOVfTkJXYNExETcB3dzSTbViOKLSR/usF
ENV AWS_SECURITY_TOKEN=FQoGZXIvYXdzEKf//////////wEaDMlxx3VJhzbyUjbhByL7AXYW1JA9aljT3Fg+NC9GYP+hWFk10UW/iDqgDP0sB70b5ERaZxeyIrkKosXJDs08TGDc9Ofm1rT1YcadhDIAkNwL45xqwjxpWoW95bi6/vFHjVQ6VrUB0OijJMxvWuVWNzSQ/pp/tduSOc8Xj9IgnzfvEPLaf3f4LY51+PftCMa3tCdpPMLgcwLB7u4MFvVl5fT3GmBNXs5Bm1/QOxQUdi7dT6r9iibFyKZnLwffTDP0G0C35eqXwhtJOnV3DcZrlg0ZIKCStIyajWlBHrhE/pWx0QubttwZMjoTv9q/iAlXwlAt5N6QI+WJOVfTkJXYNExETcB3dzSTbViOKLSR/usF

WORKDIR /app

# Handle the bash job
COPY script-fargate.sh /app/script.sh
RUN chmod +x /app/script.sh

CMD ["bash", "script.sh"]