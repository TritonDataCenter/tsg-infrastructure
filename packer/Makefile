TRITON_ACCOUNT ?= ""
TRITON_KEY_ID ?= ""
BASE_IMAGE_VERSION ?= "0.1.0"
CONSUL_VERSION ?= "1.0.6"
NOMAD_VERSION ?= "0.7.1"
COCKROACH_VERSION ?= "1.1.7"
FABIO_VERSION ?= "1.5.8"
API_SERVER_VERSION ?= "0.1.0"
SOURCE_IMAGE_VERSION ?= "0.1.0"
SOURCE_IMAGE_NAME ?= "tsg-base"

.SUFFIXES:

default: help

.PHONY: base
base:
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(BASE_IMAGE_VERSION)" \
		base.json

.PHONY: validate-base
validate-base:
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(BASE_IMAGE_VERSION)" \
		base.json

.PHONY: validate-consul-server
validate-consul-server:
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		consul-server.json

.PHONY: validate-nomad-server
validate-nomad-server:
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
validate-nomad-client:
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

.PHONY: consul-server
consul-server:
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		consul-server.json

.PHONY: nomad-server
nomad-server:
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
nomad-client:
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
api-server: ## Build the API Server template.
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
fabio: validate-fabio ## Validate the Fabio template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "fabio_version=$(FABIO_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		fabio.json

.PHONY: help
help: ## Show this help screen.
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN { FS = ":.*?## " }; { printf "%-30s %s\n", $$1, $$2 }'
	@echo ''
