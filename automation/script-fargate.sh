#!/bin/bash

aws s3 cp s3://mamip-artifacts/runbook.sh /tmp/ --region eu-west-1
bash /tmp/runbook.sh
