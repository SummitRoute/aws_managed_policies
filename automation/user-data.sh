#!/bin/bash

DATE=`date +%Y-%m-%d-%H-%M`

# job preparation
aws s3 cp s3://mamip-artifacts/script-ec2.sh /home/ec2-user/script.sh

# run job
sudo chmod +x /home/ec2-user/script.sh
sudo sh -x /home/ec2-user/script.sh >> /tmp/output.log

# copy log file
echo "Copy log file to S3"
aws s3 cp /tmp/output.log s3://mamip-artifacts/logs/output-$DATE.log --region eu-west-1