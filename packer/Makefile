TRITON_ACCOUNT ?= ""
TRITON_KEY_ID ?= ""
BASE_IMAGE_VERSION ?= "0.1.0"
CONSUL_VERSION ?= "1.0.6"
NOMAD_VERSION ?= "0.7.1"
COCKROACH_VERSION ?= "1.1.7"
FABIO_VERSION ?= "1.5.8"
LEVANT_VERSION ?= "0.1.0"
DEPLOYMENT_VERSION ?= "0.1.0"
API_SERVER_VERSION ?= "0.1.0"
SOURCE_IMAGE_VERSION ?= "0.1.0"
SOURCE_IMAGE_NAME ?= "tsg-base"

.SUFFIXES:

default: help

.PHONY: validate-base
validate-base: ## Validate the Base template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(BASE_IMAGE_VERSION)" \
		base.json

.PHONY: validate-consul-server
validate-consul-server: ## Validate the Consul Server template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		consul-server.json

.PHONY: validate-nomad-server
validate-nomad-server: ## Validate the Nomad Server template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "name=tsg-nomad-server" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "nomad_deployment_type=server" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		nomad.json

.PHONY: validate-nomad-client
validate-nomad-client: ## Validate the Nomad Client template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "name=tsg-nomad-client" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "nomad_deployment_type=client" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		nomad.json

.PHONY: validate-cockroach
validate-cockroach: ## Validate the CockroachDB template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "cockroach_version=$(COCKROACH_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		cockroach.json

.PHONY: validate-api-server
validate-api-server: ## Validate the API Server template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(API_SERVER_VERSION)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		api-server.json

.PHONY: validate-fabio
validate-fabio: ## Validate the Fabio template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "fabio_version=$(FABIO_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		fabio.json

.PHONY: validate-deployment
validate-deployment: ## Validate the Deployment template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(DEPLOYMENT_VERSION)" \
		-var "cockroach_version=$(COCKROACH_VERSION)" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "levant_version=$(LEVANT_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		deployment.json

.PHONY: base
base: validate-base ## Build the Base template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(BASE_IMAGE_VERSION)" \
		base.json

.PHONY: consul-server
consul-server: validate-consul-server ## Build the Consul Server template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		consul-server.json

.PHONY: nomad-server
nomad-server: validate-nomad-server ## Build the Nomad Server template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "name=tsg-nomad-server" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "nomad_deployment_type=server" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		nomad.json

.PHONY: nomad-client
nomad-client: validate-nomad-client ## Build the Nomad Client template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "name=tsg-nomad-client" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "nomad_deployment_type=client" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		nomad.json

.PHONY: cockroach
cockroach: validate-cockroach ## Build the CockroachDB template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "cockroach_version=$(COCKROACH_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		cockroach.json

.PHONY: api-server
api-server: validate-api-server ## Build the API Server template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(API_SERVER_VERSION)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		api-server.json

.PHONY: fabio
fabio: validate-fabio ## Build the Fabio template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "fabio_version=$(FABIO_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		fabio.json

.PHONY: deployment
deployment: validate-deployment ## Build the Deployment template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(DEPLOYMENT_VERSION)" \
		-var "cockroach_version=$(COCKROACH_VERSION)" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "levant_version=$(LEVANT_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		deployment.json

.PHONY: help
help: ## Show this help screen.
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN { FS = ":.*?## " }; { printf "%-30s %s\n", $$1, $$2 }'
	@echo ''
