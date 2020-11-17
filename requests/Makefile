LAYER_NAME?=$(shell basename $(shell pwd))
PIPELINE_ARTIFACTS_BUCKET?=
PACKAGE_PATH?=python/lib/python3.7/site-packages/

all: install zip upload
test: install zip

install:
	mkdir -p $(PACKAGE_PATH)
	pip install -t ./python/lib/python3.7/site-packages/ $(LAYER_NAME)
	pip install -t ./python/lib/python3.8/site-packages/ $(LAYER_NAME)

zip:
	zip -r9 package.zip ./python/lib/python3.7/site-packages/ ./python/lib/python3.8/site-packages/

upload:
	aws s3 cp package.zip s3://$(PIPELINE_ARTIFACTS_BUCKET)/$(LAYER_NAME)/package.zip