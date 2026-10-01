.PHONY: terraform-fmt terraform-validate terraform-init-bootstrap terraform-plan-bootstrap terraform-apply-bootstrap terraform-init-infra terraform-plan terraform-validate-infra kubeconfig

BOOTSTRAP_DIR := terraform/bootstrap
INFRA_DIR     := terraform/infrastructure

terraform-fmt:
	terraform fmt -recursive terraform

terraform-init-bootstrap:
	terraform -chdir=$(BOOTSTRAP_DIR) init

terraform-validate:
	terraform -chdir=$(BOOTSTRAP_DIR) init -backend=false -input=false
	terraform -chdir=$(BOOTSTRAP_DIR) validate
	terraform -chdir=$(INFRA_DIR) init -backend=false -input=false
	terraform -chdir=$(INFRA_DIR) validate

terraform-plan-bootstrap:
	terraform -chdir=$(BOOTSTRAP_DIR) plan -input=false

terraform-apply-bootstrap:
	terraform -chdir=$(BOOTSTRAP_DIR) apply -input=false

terraform-init-infra:
	terraform -chdir=$(INFRA_DIR) init -backend-config=backend.hcl

terraform-plan:
	terraform -chdir=$(INFRA_DIR) plan -input=false

terraform-validate-infra:
	terraform -chdir=$(INFRA_DIR) validate

kubeconfig:
	@echo "Writing gitignored kubeconfig from Terraform output"
	terraform -chdir=$(INFRA_DIR) output -raw kube_config | python -c "import sys,base64; sys.stdout.write(base64.b64decode(sys.stdin.read()).decode())" > kubeconfig
	@echo "Export with: export KUBECONFIG=$$PWD/kubeconfig"
