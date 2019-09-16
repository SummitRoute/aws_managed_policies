
help:
	@echo "all - package + update-script + deploy"
	@echo "clean - clean the build folder"
	@echo "clean-layer - clean the layer folder"
	@echo "cleaning - clean build and layer folders"
	@echo "deploy - deploy the lambda function"
	@echo "layer - prepare the layer"
	@echo "package - prepare the package"
	@echo "update-script - update the bash script on S3 bucket"

project ?= mamip
S3_BUCKET ?= ${project}-artifacts
AWS_REGION ?= eu-west-1
env ?= dev

package: clean
	@echo "Consolidating python code in ./automation/build"
	mkdir -p ./automation/build

	cp -R automation/*.py ./automation/build/
	cp -R automation/user-data.sh ./automation/build/

	@echo "zipping python code, uploading to S3 bucket, and transforming template"
	aws cloudformation package \
			--template-file automation/cfn-ec2/sam.yml \
			--s3-bucket ${S3_BUCKET} \
			--output-template-file automation/build/template-lambda.yml

	@echo "Copying updated cloud template to S3 bucket"
	aws s3 cp automation/build/template-lambda.yml 's3://${S3_BUCKET}/template-lambda.yml'

update-script:
	@echo "Copying update script.sh in artifacts s3 bucket"
	aws s3 cp automation/script.sh 's3://${S3_BUCKET}/script.sh'

layer: clean-layer
	pip3 install \
			--isolated \
			--disable-pip-version-check \
			-Ur requirements.txt -t ./layer/

clean-layer:
	@rm -fr layer/
	@rm -fr dist/
	@rm -fr htmlcov/
	@rm -fr site/
	@rm -fr .eggs/
	@rm -fr .tox/
	@find . -name '*.egg-info' -exec rm -fr {} +
	@find . -name '.DS_Store' -exec rm -fr {} +
	@find . -name '*.egg' -exec rm -f {} +
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f {} +
	@find . -name '__pycache__' -exec rm -fr {} +

clean:
	@rm -fr build/
	@rm -fr automation/build/
	@rm -fr dist/
	@rm -fr htmlcov/
	@rm -fr site/
	@rm -fr .eggs/
	@rm -fr .tox/
	@find . -name '*.egg-info' -exec rm -fr {} +
	@find . -name '.DS_Store' -exec rm -fr {} +
	@find . -name '*.egg' -exec rm -f {} +
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f {} +
	@find . -name '__pycache__' -exec rm -fr {} +

cleaning: clean clean-layer

deploy:
	aws cloudformation deploy \
			--template-file automation/build/template-lambda.yml \
			--region ${AWS_REGION} \
			--stack-name "${project}-${env}" \
			--parameter-overrides env=${env} \
			--capabilities CAPABILITY_IAM \
			--no-fail-on-empty-changeset

all: package update-script deploy
	@echo "Installation Successfull"
