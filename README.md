# [MAMIP] Monitor AWS Managed IAM Policies :loudspeaker:

Thanks to [@0xdabbad00](https://github.com/0xdabbad00) from [SummitRoute](https://summitroute.com/) for the original idea, this repo only automate the retrieval of new AWS Managed IAM Policies make it easier to monitor and get alerted when changes occurs using "Watch" feature of Github.

## Usage

### Two options

1. Activate `Releases Only` feature of Github

![setup](assets/watching.gif)

2. Subscribe to the Github [RSS Feed](https://github.com/z0ph/aws_managed_policies/commits/master.atom) (master branch)

## How it works behind the scene

These are acquired as follows:

```bash
aws iam list-policies > list-policies.json
cat list-policies.json | jq -cr '.Policies[] | select(.Arn | contains("iam::aws"))|.Arn +" "+ .DefaultVersionId+" "+.PolicyName' | xargs -n3 sh -c 'aws iam get-policy-version --policy-arn $1 --version-id $2 > "policies/$3"' sh
```

This does the following:

- Gets the list of all policies in the account
- Finds the ones with an ARN containing `iam::aws`, so that only the AWS managed policies are grabbed.
- Gets the ARN, current version id, and policy name (needed so we don't have a slash like the ARN does for writing a file)
- Calls `aws iam get-policy-version` with those values, and writes the output to a file using the policy name.

### Automation Steps

- Update the EC2 system
- Install requirements: `git`, `jq`, `SSH private key`
- Clone the repository
- Run the magic (previous command)
- Commit changes if any
- Push (with tags)

#### Schedule

- Once a day - Seattle timezone (PDT/PST). (where the magic happens :smile:)

### Schema

![schema](assets/schema.png)