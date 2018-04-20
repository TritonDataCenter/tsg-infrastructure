.PHONY: validate-us-east-1a-spc
validate-us-east-1a-spc: ##Validate US-East-1A SPC Template
	levant render -var-file=us-east-1a-spc.tf template.nomad

.PHONY: deploy-us-east-1a-spc
deploy-us-east-1a-spc: ##Deploy US-East-1A SPC
	levant deploy -log-level=debug -var-file=us-east-1a-spc.tf template.nomad

.PHONY: help
help: ## Show this help screen.
	@echo 'Usage: make <OPTIONS> ... <TARGETS>'
	@echo ''
	@echo 'Available targets are:'
	@echo ''
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN { FS = ":.*?## " }; { printf "%-30s %s\n", $$1, $$2 }'
	@echo ''

