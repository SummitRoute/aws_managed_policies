#!/usr/bin/env python3

"""
Get all AWS Managed Policies and output the current version
"""

import datetime
import json

import boto3


IAM_CLIENT = boto3.client("iam")


def use_aws_timestamp_fmt(o):
    """
    Convert Timestamps to the ISO 8601 Variation AWS Uses
    """
    if isinstance(o, (datetime.date, datetime.datetime)):
        return o.strftime("%Y-%m-%dT%H:%M:%SZ")


def get_all_aws_iam_policies(max_items=100):
    """
    Yield all current AWS Managed IAM Policies
    """
    has_more = True
    marker = None

    while has_more is True:
        if marker:
            resp = IAM_CLIENT.list_policies(
                Scope="AWS", MaxItems=max_items, Marker=marker
            )
        else:
            resp = IAM_CLIENT.list_policies(Scope="AWS", MaxItems=max_items)

        for policy in resp["Policies"]:
            yield policy

        has_more = resp["IsTruncated"]

        if has_more:
            marker = resp["Marker"]


def update_policy_version_doc(policy):
    with open("policies/" + policy["PolicyName"], "w") as fw:
        response = IAM_CLIENT.get_policy_version(
            PolicyArn=policy["Arn"], VersionId=policy["DefaultVersionId"]
        )

        del response["ResponseMetadata"]

        json.dump(response, fw, default=use_aws_timestamp_fmt, indent=4)
        fw.write("\n")  # Old process included a newline


def main():
    for policy in get_all_aws_iam_policies():
        update_policy_version_doc(policy)


if __name__ == "__main__":
    main()
