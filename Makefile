# Forwards all targets to scripts/Makefile.
# Keeps the project root clean — all build logic lives in scripts/Makefile.
# Usage: make <target> [VARIABLE=value]

SCRIPTS_MAKEFILE := scripts/Makefile

%:
	@$(MAKE) -f $(SCRIPTS_MAKEFILE) $@ $(MAKEFLAGS)
