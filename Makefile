PLAYBOOK ?= playbooks/site.yml
TAGS ?= homebrew
VARS ?= vars/vars.yml
COLLECTIONS_REQ ?= collections/requirements.yml

.PHONY: test check deps run run-homebrew run-dock run-shell run-tmux run-update

test: deps
	$(MAKE) check VARS=vars/vars-tests.yml

check:
	ansible-playbook $(PLAYBOOK) --tags $(TAGS) --check --diff -e @$(VARS)

run:
	ansible-playbook $(PLAYBOOK) -e @$(VARS)

run-homebrew:
	ansible-playbook $(PLAYBOOK) --tags homebrew -e @$(VARS)

run-dock:
	ansible-playbook $(PLAYBOOK) --tags dock -e @$(VARS)

run-shell:
	ansible-playbook $(PLAYBOOK) --tags shell -e @$(VARS)

run-tmux:
	ansible-playbook $(PLAYBOOK) --tags tmux -e @$(VARS)

run-update:
	ansible-playbook $(PLAYBOOK) --tags update -e @$(VARS)

deps:
	ansible-galaxy collection install -r $(COLLECTIONS_REQ) -p collections
