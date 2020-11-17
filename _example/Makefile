LAYER_NAME?=$(shell basename $(shell pwd))
PIPELINE_ARTIFACTS_BUCKET?=
PACKAGE_PATH?=python/lib/python3.7/site-packages/

all: install zip upload
test: install zip

install:
	mkdir -p $(PACKAGE_PATH)
	pip install -t ./$(PACKAGE_PATH) $(LAYER_NAME)

zip:
	zip -r9 package.zip $(PACKAGE_PATH)

upload:
	aws s3 cp package.zip s3://$(PIPELINE_ARTIFACTS_BUCKET)/$(LAYER_NAME)/package.zip