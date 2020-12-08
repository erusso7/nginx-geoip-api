IMAGE_NAME := quay.io/typeform/goepip-api
NGINX := 1.19.5
GEOIP_MOD:= 3.3
VERSION := dev
PORT := 80
SERVICE_NAME := geoip-api

help: ## Prints this help.
	echo $(VERSION) ${VERSION}
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the docker image
	docker build \
		--build-arg NGINX=$(NGINX) \
		--build-arg GEOIP_MOD=$(GEOIP_MOD) \
		-t $(IMAGE_NAME):$(VERSION) \
		.

run: ## Run the service locally
	docker run --rm --name $(SERVICE_NAME) -p $(PORT):80 -d $(IMAGE_NAME):$(VERSION)

stop: ## Stop the service
	docker stop $(SERVICE_NAME)