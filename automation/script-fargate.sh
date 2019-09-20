#!/bin/bash

# Docker version of the script

DATE=`date +%Y-%m-%d-%H-%M`

# job preparation (SSH + Git)
echo "Job preparation"
aws s3 cp s3://mamip-artifacts/mamip /tmp/mamip.key --region eu-west-1
chmod 600 /tmp/mamip.key
eval "$(ssh-agent -s)"
ssh-add /tmp/mamip.key
git config --global user.name "Mamip Bot"
git config --global user.email mamip_bot@github.com
mkdir -p /root/.ssh/
ssh-keyscan github.com >> /root/.ssh/known_hosts

# run the magic
echo "Git Clone"
cd /app/
git clone git@github.com:z0ph/aws_managed_policies.git -q
if [ -d /app/aws_managed_policies ]
then
    cd /app/aws_managed_policies
    echo "Run the magic"
    aws iam list-policies > /app/aws_managed_policies/list-policies.json
    cat /app/aws_managed_policies/list-policies.json | jq -cr '.Policies[] | select(.Arn | contains("iam::aws"))|.Arn +" "+ .DefaultVersionId+" "+.PolicyName' | xargs -n3 sh -c 'aws iam get-policy-version --policy-arn $1 --version-id $2 > "policies/$3"' sh
    # push the changes if any
    if [[ -n $(git status -s) ]];
    then
        echo "Tagging"
        git tag $DATE
        git push --tags
        echo "Push the changes to master"
        git add ./policies
        git commit -am "Update detected"
        git push origin master
    else
        echo "No changes detected"
    fi
fi