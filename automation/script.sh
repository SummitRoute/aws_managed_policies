#!/bin/bash

DATE=`date +%Y-%m-%d-%H-%M`

# job preparation
echo "Job preparation"
sudo yum update -y
sudo yum install git jq -y
aws s3 cp s3://mamip-artifacts/mamip /tmp/mamip.key --region eu-west-1
sudo chmod 600 /tmp/mamip.key
eval "$(ssh-agent -s)"
ssh-add /tmp/mamip.key
git config --global user.name "Mamip Bot"
git config --global user.email mamip_bot@github.com
ssh-keyscan github.com >> ~/.ssh/known_hosts

# run the magic
echo "Git Clone"
cd /tmp/
git clone git@github.com:z0ph/aws_managed_policies.git -q
cd /tmp/aws_managed_policies
echo "Run the magic"
aws iam list-policies > /tmp/aws_managed_policies/list-policies.json
cat /tmp/aws_managed_policies/list-policies.json | jq -cr '.Policies[] | select(.Arn | contains("iam::aws"))|.Arn +" "+ .DefaultVersionId+" "+.PolicyName' | xargs -n3 sh -c 'aws iam get-policy-version --policy-arn $1 --version-id $2 > "policies/$3"' sh

# push the changes if any
if [[ -n $(git status -s) ]];
then
    echo "Tagging"
    git tag $DATE
    git push --tags
    echo "Push the changes to master"
    git commit -am "Update detected"
    git push origin master
else
    echo "No changes detected"
fi

# cleaning
echo "Cleaning"
rm -rf /tmp/aws_managed_policies/
rm -f /tmp/mamip.key

echo "End."
# terminate EC2 instance once the job is complete
aws ec2 terminate-instances --instance-ids `curl http://169.254.169.254/latest/meta-data/instance-id` --region eu-west-1