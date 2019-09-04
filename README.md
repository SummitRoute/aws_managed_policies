Collection of the AWS Managed IAM policies.  These are acquired by the `get_aws_managed_policies.py` script.

```
python3 auto_update_lambda/get_aws_managed_policies.py
```

This script does the following:
- Gets the list of all policies in the account with scope AWS (managed by AWS).
- Gets the ARN, current version id, and policy name (needed so we don't have a slash like the ARN does for writing a file)
- Calls `get-policy-version` with those values, and writes the output to a file using the policy name.
