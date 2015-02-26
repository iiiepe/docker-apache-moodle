CURRENT_DIRECTORY := $(shell pwd)

build:
	@docker build --tag=iiiepe/apache-moodle $(CURRENT_DIRECTORY)

.PHONY: build
