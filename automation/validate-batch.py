import boto3
import json
import glob
import os
from datetime import date

client = boto3.client('accessanalyzer')

policy_path = './policies'
analyzed_count = 0
error = 0
fail = 0
sec_warning = 0
suggestion = 0
warning = 0

# Date
today = date.today()
date = today.strftime("%Y-%m-%d")

files = [f for f in glob.glob(policy_path + "**/*", recursive=True)]

# Empty ./findings/ folder
finds = glob.glob('./findings/*')
for find in finds:
    os.remove(find)

# Validate for each AWS Managed Policy
for f in files:
    analyzed_count += 1
    with open(f) as policy:
        print("==> Validation of:", f)
        policy = policy.read()
        policy = json.loads(policy)
        # Extract IAM Document from AWS Managed Policy
        doc = json.dumps(policy['PolicyVersion']['Document'])

        # Access Analyzer - Policy Validation
        try:
            r = client.validate_policy(
                policyDocument=str(doc),
                policyType='IDENTITY_POLICY'
            )
        except Exception as e:
            fail += 1
            # Write errors to a log file
            error_output = open("./findings/fails.txt", "a")
            error_output.write(str(f) + '\n')
            error_output.write(str(e))
            error_output.close()
        
        # Extract findings from response
        findings = r['findings']
        # More readable output (json)
        readable_findings = json.dumps(findings, indent=4, sort_keys=True)
        print("==> Finding:", readable_findings)

        # Export to findings folder with a json file per AWS Managed Policy
        if len(findings) > 0:
            file_name = f.split("/")
            file_name = file_name[2]

            results = "./findings/" + file_name + ".json"
            finding_output = open(results, "a")
            finding_output.write(readable_findings)
            finding_output.close()

        # Count for stats
        for finding in findings:
            # Possible Types: 'ERROR'|'SECURITY_WARNING'|'SUGGESTION'|'WARNING'
            if finding['findingType'] == 'ERROR':
                error += 1
            if finding['findingType'] == 'SECURITY_WARNING':
                sec_warning += 1
            if finding['findingType'] == 'SUGGESTION':
                suggestion += 1
            if finding['findingType'] == 'WARNING':
                warning += 1

# Create README.md for stats
stats_output = open("./findings/README.md", "a")
stats_output.write("## Findings Stats - " + str(date) + "\n")
stats_output.write("- Policies analyzed: `" + str(analyzed_count) + "`\n")
stats_output.write("- Errors: `" + str(error) + "`\n")
stats_output.write("- Sec_Warnings: `" + str(sec_warning) + "`\n")
stats_output.write("- Suggestions: `" + str(suggestion) + "`\n")
stats_output.write("- Warnings: `" + str(warning) + "`\n")
stats_output.write("- Fails: `" + str(fail) + "`\n")
stats_output.close()

print("======== stats =======")
print("policies analyzed:", analyzed_count)
print("errors:", error)
print("sec_warnings:", sec_warning)
print("suggestions:", suggestion)
print("warnings:", warning)
print("fail:", fail)
print("======================")