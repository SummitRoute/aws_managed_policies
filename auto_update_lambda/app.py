"""
Prior to running this CDK, a few prerequisites.

1) Put the GitHub Personal Access Token Secret in AWS Secrets Manager and
setup other environmental variables.

Create a Secret in account that is the Personal Access Token for the account to
push to the target repo.

Get the ARN for the created Secret and add an environmental variable with name
AMP_GH_ACCESS_TOKEN_ARN and the ARN as the value.

The following additional environment variables need to be set.
GH_BOT_USERNAME   - Bot Username associated with the access token
GH_BOT_REPO_OWNER - GitHub Repo Owner - Username or Org
GH_BOT_COMMITTER  - Author/Committer String for Git

2) Build the Lambda Deployment Package for the Lambda Code.

```
mkdir lambda_package; cd lambda_package/
cp ../get_aws_managed_policies.py ../lambda-handler.py .
pip3 install dulwich -t .
zip -r ../deploymentPackage.zip .
```

3) Perform the normal AWS CDK Deployment process
"""


from os import environ

from aws_cdk import (
    aws_events as events,
    aws_events_targets as targets,
    aws_iam,
    aws_lambda as lambda_,
    aws_logs,
    aws_secretsmanager as secret_,
    core,
)


class AWSManagedPolicyUpdater(core.Stack):
    def __init__(self, app: core.App, id: str) -> None:
        super().__init__(app, id)

        role = aws_iam.Role(
            self,
            "getAWSPoliciesRoleLambda",
            assumed_by=aws_iam.ServicePrincipal("lambda.amazonaws.com"),
            managed_policies=[
                aws_iam.ManagedPolicy.from_aws_managed_policy_name(
                    "service-role/AWSLambdaBasicExecutionRole"
                )
            ],
        )

        aws_iam.Policy(
            self,
            "iam_list_policies",
            policy_name="iam_list_policies",
            statements=[
                aws_iam.PolicyStatement(
                    actions=[
                        "iam:GetPolicyVersion",
                        "iam:ListPolicies",
                        "iam:ListPolicyVersions",
                    ],
                    resources=["*"],
                )
            ],
            roles=[role],
        )

        secret = secret_.Secret.from_secret_attributes(
            self, "Secret", secret_arn=environ["AMP_GH_ACCESS_TOKEN_ARN"]
        )

        secret.grant_read(role)

        lambdaFn = lambda_.Function(
            self,
            "AWSManagedPolicyUpdater",
            code=lambda_.AssetCode("./deploymentPackage.zip"),
            handler="lambda-handler.main",
            timeout=core.Duration.minutes(15),
            runtime=lambda_.Runtime.PYTHON_3_7,
            role=role,
            environment={
                "GH_BOT_USERNAME": environ["GH_BOT_USERNAME"],
                "GH_BOT_REPO_OWNER": environ["GH_BOT_REPO_OWNER"],
                "GH_BOT_COMMITTER": environ["GH_BOT_COMMITTER"],
            },
        )

        # Run once every hour on the 9th minute
        # See https://docs.aws.amazon.com/lambda/latest/dg/tutorial-scheduled-events-schedule-expressions.html
        rule = events.Rule(
            self, "Rule", schedule=events.Schedule.cron(minute="9", hour="*")
        )

        rule.add_target(targets.LambdaFunction(lambdaFn))


app = core.App()
AWSManagedPolicyUpdater(app, "AWSManagedPolicyUpdater")
app.synth()
