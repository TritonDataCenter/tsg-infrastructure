TRITON_ACCOUNT ?= ""
TRITON_KEY_ID ?= ""
BASE_IMAGE_VERSION ?= "0.1.0"
CONSUL_VERSION ?= "1.0.6"
NOMAD_VERSION ?= "0.7.1"
COCKROACH_VERSION ?= "1.1.7"
SOURCE_IMAGE_VERSION ?= "0.1.0"
SOURCE_IMAGE_NAME ?= "tsg-base"

.SUFFIXES:

default: help

.PHONY: inspect-base
inspect-base: ## Inspects the contents of the TSG Base template.
	packer inspect \
		tsg-base.json

.PHONY: validate-base
validate-base: ## Validate the TSG Base template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(BASE_IMAGE_VERSION)" \
		tsg-base.json

.PHONY: validate-consul
validate-consul: ## Validate the TSG Consul template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		consul.json

.PHONY: validate-nomad-server
validate-nomad-server: ## Validate the TSG Nomad Server template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "name=nomad-server" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "nomad_deployment_type=server" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		nomad.json

.PHONY: validate-nomad-client
validate-nomad-client: ## Validate the TSG Nomad Client template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "name=nomad-client" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "nomad_deployment_type=client" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		nomad.json

.PHONY: validate-cockroach
validate-cockroach: ## Validate the TSG CockroachDB template.
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "cockroach_version=$(COCKROACH_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		cockroach.json

.PHONY: base
base: ## Build the TSG Base template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(BASE_IMAGE_VERSION)" \
		tsg-base.json

.PHONY: consul
consul: ## Build the TSG Consul template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		consul.json

.PHONY: nomad-server
nomad-server: ## Build the TSG Nomad Server template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "name=nomad-server" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "nomad_deployment_type=server" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		nomad.json

.PHONY: nomad-client
nomad-client: ## Build the TSG Nomad Client template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "name=nomad-client" \
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "nomad_deployment_type=client" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		nomad.json

.PHONY: cockroach
cockroach: ## Build the TSG CockroachDB template.
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "cockroach_version=$(COCKROACH_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		cockroach.json

.PHONY: help
help: ## Show this help screen.
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN { FS = ":.*?## " }; { printf "%-30s %s\n", $$1, $$2 }'
	@echo ''
