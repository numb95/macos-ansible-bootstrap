PLAYBOOK ?= playbooks/site.yml
TAGS ?= homebrew
VARS ?= vars/vars.yml
COLLECTIONS_REQ ?= collections/requirements.yml

.PHONY: test check deps

test: deps
	$(MAKE) check VARS=vars/vars-tests.yml

check:
	ansible-playbook $(PLAYBOOK) --tags $(TAGS) --check --diff -e @$(VARS)

deps:
	ansible-galaxy collection install -r $(COLLECTIONS_REQ) -p collections
