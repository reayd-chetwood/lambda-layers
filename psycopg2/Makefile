LAYER_NAME?=$(shell basename $(shell pwd))
PIPELINE_ARTIFACTS_BUCKET?=
PACKAGE_PATH?=python/lib/python3.7/site-packages/

all: zip

zip:
	zip -r9 package.zip $(PACKAGE_PATH)
