# make visualcheck 001   — a real test in competitiondata/ (3 digits)
# make visualcheck 0000  — a committed fixture in testdata/ (4 digits)
# Builds our question paper and answer key, then opens them beside Toebes's PDF of the same test.

ifeq (visualcheck,$(firstword $(MAKECMDGOALS)))
  TEST := $(word 2,$(MAKECMDGOALS))
  $(eval $(TEST):;@:)
endif
DIR = $(if $(wildcard testdata/$(TEST).json),testdata,competitiondata)

.PHONY: visualcheck
visualcheck:
	@test -n "$(TEST)" || { echo "Usage: make visualcheck 001 (or 0000)"; exit 1; }
	./compile.sh $(DIR)/$(TEST).json $(DIR)/$(TEST)-tct.pdf
	open $(DIR)/$(TEST)-tct.pdf $(DIR)/$(TEST).pdf $(DIR)/$(TEST)-tct-key.pdf
