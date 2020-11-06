.DEFAULT_GOAL := help

help:
	@echo "${PROJECT}"
	@echo "${DESCRIPTION}"
	@echo ""
	@echo "	build-docker - build docker image"
	@echo "	init - init IaC using Terraform"
	@echo "	validate - validate the IaC using Terraform"
	@echo "	plan - plan (dryrun) IaC using Terraform"
	@echo "	apply - deploy the IaC using Terraform"
	@echo "	destroy - delete all previously created infrastructure using Terraform"
	@echo "	clean - clean the build folder"
	@echo "	update-runbook - update the runbook script on S3 artifacts bucket"

################ Project #######################
PROJECT ?= mamip
DESCRIPTION ?= Monitor AWS Managed IAM Policies Changes
################################################

################ Config ########################
S3_BUCKET ?= zoph-lab-terraform-tfstate
ARTIFACTS_BUCKET ?= mamip-artifacts
AWS_REGION ?= eu-west-1
ENV ?= dev
ECR ?= 567589703415.dkr.ecr.eu-west-1.amazonaws.com/mamip-ecr-dev
################################################

build-docker:
	@docker build -t mamip-image ./automation/
	@docker tag mamip-image $(ECR)
	@docker push $(ECR)

################ Terraform #####################
init:
	@terraform init \
		-backend-config="bucket=$(S3_BUCKET)" \
		-backend-config="key=$(PROJECT)/terraform.tfstate" \
		./automation/tf-fargate/

validate:
	@terraform validate ./automation/tf-fargate/

plan:
	@terraform plan \
		-var="env=$(ENV)" \
		-var="project=$(PROJECT)" \
		-var="description=$(DESCRIPTION)" \
		-var="aws_region=$(AWS_REGION)" \
		-var="artifacts_bucket=$(S3_BUCKET)" \
		./automation/tf-fargate/

apply:
	@terraform apply \
		-var="env=$(ENV)" \
		-var="project=$(PROJECT)" \
		-var="description=$(DESCRIPTION)" \
		-compact-warnings ./automation/tf-fargate/

destroy:
	@read -p "Are you sure that you want to destroy: '$(PROJECT)-$(ENV)-$(AWS_REGION)'? [yes/N]: " sure && [ $${sure:-N} = 'yes' ]
	@terraform destroy ./automation/tf-fargate/

update-runbook:
	@echo "Copying runbook scripts in artifacts s3 bucket"
	aws s3 cp automation/runbook.sh 's3://${ARTIFACTS_BUCKET}/runbook.sh'

clean:
	@rm -fr build/
	@rm -fr automation/build/
	@rm -fr dist/
	@rm -fr htmlcov/
	@rm -fr site/
	@rm -fr .eggs/
	@rm -fr .tox/
	@rm -fr *.tfstate
	@rm -fr *.tfplan
	@find . -name '*.egg-info' -exec rm -fr {} +
	@find . -name '.DS_Store' -exec rm -fr {} +
	@find . -name '*.egg' -exec rm -f {} +
	@find . -name '*.pyc' -exec rm -f {} +
	@find . -name '*.pyo' -exec rm -f {} +
	@find . -name '*~' -exec rm -f {} +
	@find . -name '__pycache__' -exec rm -fr {} +
