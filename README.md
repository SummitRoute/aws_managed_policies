Collection of the AWS Managed IAM policies.  These were acquired as follows:

```
aws iam list-policies > list-policies.json
cat list-policies.json | jq -cr '.Policies[] | select(.Arn | contains("iam::aws"))|.Arn +" "+ .DefaultVersionId+" "+.PolicyName' | xargs -n3 sh -c 'aws iam get-policy-version --policy-arn $1 --version-id $2 > "policies/$3"' sh
```

This does the following:
- Gets the list of all policies in the account
- Finds the ones with an ARN containing "iam::aws", so that only the AWS managed policies are grabbed.
- Gets the ARN, current version id, and policy name (needed so we don't have a slash like the ARN does for writing a file)
- Calls `aws iam get-policy-version` with those values, and writes the output to a file using the policy name.
