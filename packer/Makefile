TRITON_ACCOUNT ?= ""
TRITON_KEY_ID ?= ""
BASE_IMAGE_VERSION ?= "0.1.0"
CONSUL_VERSION ?= "1.0.6"
NOMAD_VERSION ?= "0.7.1"
SOURCE_IMAGE_VERSION ?= "0.1.0"
SOURCE_IMAGE_NAME ?= "tsg-base"

.PHONY: base
base:
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(BASE_IMAGE_VERSION)" \
		tsg-base.json

.PHONY: inspect-base
inspect-base:
	packer inspect \
		tsg-base.json

.PHONY: validate-base
validate-base:
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "version=$(BASE_IMAGE_VERSION)" \
		tsg-base.json

.PHONY: validate-consul
validate-consul:
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		consul.json

.PHONY: validate-nomad-server
validate-nomad-server:
	packer validate \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
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
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "nomad_deployment_type=client" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		nomad.json

.PHONY: consul
consul:
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
		-var "consul_version=$(CONSUL_VERSION)" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		consul.json

.PHONY: nomad-server
nomad-server:
	packer build \
		-var "triton_account=$(TRITON_ACCOUNT)" \
		-var "triton_key_id=$(TRITON_KEY_ID)" \
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
		-var "nomad_version=$(NOMAD_VERSION)" \
		-var "nomad_deployment_type=client" \
		-var "source_machine_image=$(SOURCE_IMAGE_NAME)" \
		-var "source_machine_image_version=$(SOURCE_IMAGE_VERSION)" \
		nomad.json

.PHONY: help
help:
	@echo "Valid targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
