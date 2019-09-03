#!/bin/bash

DATE=`date +%Y-%m-%d-%H-%M`

# job preparation
aws s3 cp s3://mamip-artifacts/script.sh /home/ec2-user/

# run job
sudo chmod +x /home/ec2-user/script.sh
sudo sh -x /home/ec2-user/script.sh >> /tmp/log.out

# copy log file
echo "Copy log file to S3"
aws s3 cp /tmp/log.out s3://mamip-artifacts/logs/log-$DATE.out --region eu-west-1