APPLICATION_STACK_NAME?=LambdaLayers
GITHUB_OAUTH_TOKEN?=$(shell bash -c 'read -p "GITHUB_OAUTH_TOKEN: " var; echo $$var')
GITHUB_REPO?=aws-lambda-layers
GITHUB_OWNER?=reayd-chetwood
GITHUB_BRANCH?=master
PROFILE?=$(APPLICATION_STACK_NAME)-$(ENVIRONMENT)
AWS_DEFAULT_REGION?=
PIPELINE_ARTIFACTS_BUCKET?=


build:
	$(MAKE) -C psycopg2
	$(MAKE) -C lambdakube

upload:
	aws s3 sync . s3://$(PIPELINE_ARTIFACTS_BUCKET)/aws-lambda-layers/cloudformation/ --exclude "*" --include "layer.yml" --delete
	aws s3 sync . s3://$(PIPELINE_ARTIFACTS_BUCKET)/aws-lambda-layers/ --exclude "*" --include "**/package.zip" --delete

# Do this first to configure the awscli
setup_aws:
	$(eval ENVIRONMENT := $(shell bash -c 'read -p "ENVIRONMENT [dev, test, prod]: " var; echo $$var'))
	aws configure --profile $(PROFILE)

# Function to create a pipeline - can't be automated
pipeline:
	$(eval ENVIRONMENT := $(shell bash -c 'read -p "ENVIRONMENT [dev, test, prod]: " var; echo $$var'))
	-@unset AWS_DEFAULT_REGION; \
	aws cloudformation create-stack \
		--profile $(PROFILE) \
		--stack-name Pipeline$(APPLICATION_STACK_NAME) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--template-body file://pipeline.yml \
		--output text \
		--parameters \
		  ParameterKey=ApplicationStackName,ParameterValue=$(APPLICATION_STACK_NAME) \
		  ParameterKey=GitHubOAuthToken,ParameterValue=$(GITHUB_OAUTH_TOKEN) \
		  ParameterKey=GitHubOwner,ParameterValue=$(GITHUB_OWNER) \
		  ParameterKey=GitHubRepo,ParameterValue=$(GITHUB_REPO) \
		  ParameterKey=GitHubBranch,ParameterValue=$(GITHUB_BRANCH) \
		  ParameterKey=Environment,ParameterValue=$(ENVIRONMENT)

# Function to update a pipeline after its been created - can't be automated
update_pipeline:
	$(eval ENVIRONMENT := $(shell bash -c 'read -p "ENVIRONMENT [dev, test, prod]: " var; echo $$var'))
	-@unset AWS_DEFAULT_REGION; \
	aws cloudformation update-stack \
		--profile $(PROFILE) \
		--stack-name Pipeline$(APPLICATION_STACK_NAME) \
		--capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--template-body file://pipeline.yml \
		--output text \
		--parameters \
		  ParameterKey=ApplicationStackName,ParameterValue=$(APPLICATION_STACK_NAME) \
		  ParameterKey=GitHubOAuthToken,ParameterValue=$(GITHUB_OAUTH_TOKEN) \
		  ParameterKey=GitHubOwner,ParameterValue=$(GITHUB_OWNER) \
		  ParameterKey=GitHubRepo,ParameterValue=$(GITHUB_REPO) \
		  ParameterKey=GitHubBranch,ParameterValue=$(GITHUB_BRANCH) \
		  ParameterKey=Environment,ParameterValue=$(ENVIRONMENT)

# Command to aid CI/CD and CloudFormation development
release:
	@git status
	$(eval COMMENT := $(shell bash -c 'read -e -p "Comment: " var; echo $$var'))
	@git add --all; \
	 git commit -m "$(COMMENT)"; \
	 git push
