IMAGE_NAME := quay.io/typeform/goepip-api
NGINX := 1.19.5
GEOIP_MOD := 3.3
GEOIPUPDATE := 4.5.0
VERSION := dev
PORT := 80
SERVICE_NAME := geoip-api
MAXMIND_PRODUCTS := "GeoLite2-City"

help: ## Prints this help.
	echo $(VERSION) ${VERSION}
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the docker image
	@docker build \
		--build-arg NGINX=$(NGINX) \
		--build-arg GEOIP_MOD=$(GEOIP_MOD) \
		--build-arg GEOIPUPDATE=$(GEOIPUPDATE) \
		-t $(IMAGE_NAME):$(VERSION) \
		.

run: ## Run the service locally
	@docker run \
		--name $(SERVICE_NAME) \
		-p $(PORT):80 \
		-e MAXMIND_ACCOUNT="$(MAXMIND_ACCOUNT)" \
		-e MAXMIND_KEY="$(MAXMIND_KEY)" \
		-e MAXMIND_PRODUCTS="$(MAXMIND_PRODUCTS)" \
		-e JOB_SCHEDULE="$(JOB_SCHEDULE)" \
		--rm \
		-d \
		$(IMAGE_NAME):$(VERSION)

stop: ## Stop the service
	@docker stop $(SERVICE_NAME)

exec: ## Start an interactive shell with the container
	@docker exec -it $(shell docker ps -f name=$(SERVICE_NAME) -q) sh
