# [MAMIP] Monitor AWS Managed IAM Policies :loudspeaker:

![[Prod] MAMIP - GitHub Actions](https://github.com/z0ph/aws_managed_policies/workflows/%5BProd%5D%20MAMIP%20-%20GitHub%20Actions/badge.svg)

Thanks to [@0xdabbad00](https://github.com/0xdabbad00) from [SummitRoute](https://summitroute.com/) for the original idea, this repo only automate the retrieval of new AWS Managed IAM Policies make it easier to monitor and get alerted when changes occur using "Watch" feature of Github or [Twitter Account](https://twitter.com/mamip_aws).

I'm using this excuse for learning and experiment with new stuff: Automation, Terraform, and Containers with AWS Fargate (SPOT).

## Usage

### Three options

1. Follow the [dedicated Twitter Account](https://twitter.com/mamip_aws).

2. Activate `Releases Only` feature of Github

![setup](assets/watching.gif)

3. Subscribe to the Github [RSS Feed](https://github.com/z0ph/aws_managed_policies/commits/master.atom) (master branch)

## How it works behind the scene

These are acquired as follows:

```bash
aws iam list-policies > list-policies.json
cat list-policies.json \
  | jq -cr '.Policies[] | select(.Arn | contains("iam::aws"))|.Arn +" "+ .DefaultVersionId+" "+.PolicyName' \
  | xargs -n3 sh -c 'aws iam get-policy-version --policy-arn $1 --version-id $2 > "policies/$3"' sh
```

This does the following:

- Gets the list of all IAM Policies in the AWS account
- Finds the ones with an ARN containing `iam::aws`, so that only the AWS managed policies are grabbed.
- Gets the `ARN`, current version id, and policy name (needed so we don't have a slash as the `ARN` does for writing a file)
- Calls `aws iam get-policy-version` with those values, and writes the output to a file using the policy name.

### Automation Details

- Infrastructure is deployed using:
  - ECS/Fargate: Terraform
- Clone this repository
- Run the magic (previously mentioned command)
- If changes detected:
  - Commit changes
  - Push (with tags for GH release)
  - Push to [qTweet](https://github.com/z0ph/qtweet)

#### Schedule

- ECS/Fargate (Spot): **Every 4 hours**

### Architecture Design

![Schema ECS Fargate](assets/schemav2.png)