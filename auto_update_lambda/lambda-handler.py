import base64
import os

import boto3
from botocore.exceptions import ClientError

from dulwich import porcelain
from get_aws_managed_policies import *


def get_secret():
    """
    AWS Provided Get Secret Code
    """
    secret_name = "AMP_GH_ACCESS_TOKEN"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager")

    # In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    # See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    # We rethrow the exception by default.

    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        if e.response["Error"]["Code"] == "DecryptionFailureException":
            # Secrets Manager can't decrypt the protected secret text using the provided KMS key.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response["Error"]["Code"] == "InternalServiceErrorException":
            # An error occurred on the server side.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response["Error"]["Code"] == "InvalidParameterException":
            # You provided an invalid value for a parameter.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response["Error"]["Code"] == "InvalidRequestException":
            # You provided a parameter value that is not valid for the current state of the resource.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
        elif e.response["Error"]["Code"] == "ResourceNotFoundException":
            # We can't find the resource that you asked for.
            # Deal with the exception here, and/or rethrow at your discretion.
            raise e
    else:
        # Decrypts secret using the associated KMS CMK.
        # Depending on whether the secret is a string or binary, one of these fields will be populated.

        if "SecretString" in get_secret_value_response:
            secret = get_secret_value_response["SecretString"]

    return secret


def update_repo(
    github_bot_username,
    gh_access_token,
    repo_owner,
    repo_path="/tmp/aws_managed_policies",
):
    remote_repo = (
        "https://"
        + github_bot_username
        + ":"
        + gh_access_token
        + "@github.com/"
        + repo_owner
        + "/aws_managed_policies"
    )

    if os.path.isdir(repo_path):
        porcelain.pull(repo_path, remote_location=remote_repo)
    else:
        porcelain.clone(remote_repo, repo_path)

    os.chdir(repo_path)


def commit_any_changes(
    github_bot_username,
    gh_access_token,
    repo_owner,
    committer,
    repo_path="/tmp/aws_managed_policies",
):
    remote_repo = (
        "https://"
        + github_bot_username
        + ":"
        + gh_access_token
        + "@github.com/"
        + repo_owner
        + "/aws_managed_policies"
    )

    os.chdir(repo_path)
    repo = porcelain.open_repo(repo_path)
    status = porcelain.status(repo_path)

    # Nothing changed - exit
    if len(status.unstaged + status.untracked) == 0:
        return

    repo.stage(status.unstaged + status.untracked)

    porcelain.commit(
        repo_path,
        message="Update Managed Policies",
        author=committer,
        committer=committer,
    )
    porcelain.push(repo_path, remote_repo, "master")


def main(event, context):
    GH_ACCESS_TOKEN = get_secret()

    update_repo(
        os.environ["GH_BOT_USERNAME"], GH_ACCESS_TOKEN, os.environ["GH_BOT_REPO_OWNER"]
    )
    get_all_aws_managed_policies()
    commit_any_changes(
        os.environ["GH_BOT_USERNAME"],
        GH_ACCESS_TOKEN,
        os.environ["GH_BOT_REPO_OWNER"],
        os.environ["GH_BOT_COMMITTER"],
    )
