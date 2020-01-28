import boto3
import base64

with open("user-data.sh", "rb") as userdata_script:
    encoded_userdata = base64.b64encode(userdata_script.read())
    encoded_userdata = encoded_userdata.decode()
    print(encoded_userdata)

ec2 = boto3.client('ec2')
def lambda_handler(event, context):
    ec2.request_spot_instances(
        SpotPrice='0.1',
        InstanceCount=1,
        Type='one-time',
        LaunchSpecification={
            'ImageId': 'ami-0bbc25e23a7640b9b',
            'KeyName': 'mamip-keypair2',
            'InstanceType': 't3.nano',
            'UserData': encoded_userdata,
            'IamInstanceProfile': {
                'Arn': 'arn:aws:iam::567589703415:instance-profile/mamip-instance-role'
            },
            'SecurityGroupIds': ['sg-00b1e08a72cdc96d8']
        }
)