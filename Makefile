cwd := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
env_file := $(cwd)/.env
tf_approve_opts = --auto-approve
TF_VAR_aws_access_key = ${AWS_ACCESS_KEY_ID}
TF_VAR_aws_secret_key = ${AWS_SECRET_ACCESS_KEY}

ifneq ("$(wildcard $(env_file))","")
	include $(env_file)
	export
endif

wrap_targets := terraform tf
ifneq ($(filter $(firstword $(MAKECMDGOALS)), $(wrap_targets)), )
  RUN_ARGS := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
  $(eval $(RUN_ARGS):;@:)
endif

all: version init apply
	@echo Done!
	@echo Please run: 'eval $$(make config)'

env:
	@env

version:
	terraform --version

config:
	@echo export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
	@echo export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply ${tf_approve_opts}
ssh:
	$(eval ssh_host = $(shell terraform output ssh_connection))
	ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -t $(ssh_host) "cd /tmp; sudo bash"
