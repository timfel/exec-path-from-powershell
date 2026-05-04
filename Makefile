EMACS ?= emacs
PACKAGE := exec-path-from-powershell
HOME_DIR ?= $(CURDIR)/.home
MELPA_DIR ?= ../melpa
MELPA_RECIPE := packaging/melpa/$(PACKAGE)
MELPA_USER_CONFIG := "(setq package-build-badge-data nil)"

export HOME := $(HOME_DIR)

.PHONY: check lint test sync-melpa-recipe melpa-check melpa-sandbox melpa-stable-check melpa-stable-sandbox clean

check: lint test

lint: $(HOME)/.emacs.d
	$(EMACS) -Q --batch -l scripts/quality-check.el $(PACKAGE).el

test: $(HOME)/.emacs.d
	$(EMACS) -Q --batch -l scripts/test-batch.el

sync-melpa-recipe:
	install -m 0644 $(MELPA_RECIPE) $(MELPA_DIR)/recipes/$(PACKAGE)

melpa-check: sync-melpa-recipe
	$(MAKE) -C $(MELPA_DIR) USER_CONFIG='$(MELPA_USER_CONFIG)' recipes/$(PACKAGE)

melpa-sandbox: sync-melpa-recipe
	$(MAKE) -C $(MELPA_DIR) sandbox INSTALL=$(PACKAGE)

melpa-stable-check: sync-melpa-recipe
	MELPA_CHANNEL=stable $(MAKE) -C $(MELPA_DIR) USER_CONFIG='$(MELPA_USER_CONFIG)' recipes/$(PACKAGE)

melpa-stable-sandbox: sync-melpa-recipe
	MELPA_CHANNEL=stable $(MAKE) -C $(MELPA_DIR) sandbox INSTALL=$(PACKAGE)

$(HOME)/.emacs.d:
	mkdir -p $(HOME)/.emacs.d

clean:
	rm -f $(PACKAGE)-autoloads.el $(PACKAGE).elc test/*.elc
