SHELL := /bin/sh
.DEFAULT_GOAL := help

STOW ?= stow
ifneq ($(filter command,$(origin ACTION) $(origin DRY_RUN)),)
$(error Use S/R/D and N targets instead of ACTION= or DRY_RUN=)
endif
override ACTION := $(or $(sort $(filter S R D,$(MAKECMDGOALS))),S)
override DRY_RUN := $(filter N,$(MAKECMDGOALS))

# Bootstrap XDG without depending on an already installed shell configuration.
ifeq ($(strip $(XDG_CONFIG_HOME)),)
override XDG_CONFIG_HOME := $(HOME)/.config
endif
export XDG_CONFIG_HOME

# Every top-level directory with a .stowrc is a Stow group.
STOW_DIRS := $(patsubst %/.stowrc,%,$(wildcard */.stowrc))
PACKAGES := $(sort $(foreach dir,$(STOW_DIRS),$(notdir $(patsubst %/,%,$(wildcard $(dir)/*/)))))
RESERVED := help list check S R D N

ifneq ($(word 2,$(ACTION)),)
$(error Select only one action: S, R, or D)
endif
ifneq ($(filter S R D N,$(MAKECMDGOALS)),)
ifeq ($(filter $(PACKAGES),$(MAKECMDGOALS)),)
$(error Specify at least one package with S, R, D, or N. Run make list)
endif
endif
ifneq ($(filter $(RESERVED),$(PACKAGES)),)
$(error Reserved package names: $(filter $(RESERVED),$(PACKAGES)))
endif
ifneq ($(filter-out $(RESERVED) $(PACKAGES),$(MAKECMDGOALS)),)
$(error Unknown package or command: $(filter-out $(RESERVED) $(PACKAGES),$(MAKECMDGOALS)). Run make list)
endif

# Stow operations can share destination directories, even across packages.
.NOTPARALLEL:
.PHONY: $(RESERVED) $(PACKAGES)

STOW_ACTION_S := stow
STOW_ACTION_R := restow
STOW_ACTION_D := delete

# Relative Git includes need a real target directory, not a folded symlink.
STOW_FLAGS_git := --no-folding

S R D N: ; @:

# Read the target so new groups need no Makefile changes to create it.
# Perl and Text::ParseWords are already required by GNU Stow. Match its resource
# file quoting and expand variables without evaluating configuration as shell code.
define stow_target
perl -MText::ParseWords=shellwords -MGetopt::Long=GetOptionsFromArray -e '\
    my @options; \
    for my $$file ("$$ENV{HOME}/.stowrc", ".stowrc") { \
        next unless -f $$file; \
        open my $$fh, "<", $$file or die "Cannot read $$file: $$!\n"; \
        while (<$$fh>) { push @options, shellwords($$_); } \
    } \
    Getopt::Long::Configure("pass_through"); \
    my $$target; \
    GetOptionsFromArray(\@options, "target|t=s" => \$$target) or die "Invalid Stow target\n"; \
    defined $$target && length $$target or die "Set --target in .stowrc\n"; \
    $$target =~ s/(?<!\\)\$$\{(\w+)\}|(?<!\\)\$$(\w+)/ \
        my $$name = defined $$1 ? $$1 : $$2; \
        exists $$ENV{$$name} ? $$ENV{$$name} : die "Undefined environment variable: $$name\n"; \
    /ge; \
    $$target =~ s{^~([^/]*)}{length $$1 ? (getpwnam($$1))[7] : $$ENV{HOME}}e; \
    $$target =~ s/\\([\$$~])/$$1/g; \
    length $$target or die "Empty Stow target\n"; \
    print $$target;'
endef

help:
	@printf '%s\n' \
	  'Dotfiles (GNU Make and GNU Stow)' \
	  '' \
	  '  make list                       list packages and their Stow groups' \
	  '  make tmux zsh                   stow selected packages (S is the default)' \
	  '  make S zsh                      stow explicitly' \
	  '  make R zsh                      restow links' \
	  '  make D zsh                      delete links' \
	  '  make N zsh                      simulate stow' \
	  '  make R N zsh                    simulate restow' \
	  '' \
	  'S/R/D and N may appear anywhere; they apply to every requested package.' \
	  'Run from the repository root. Each group .stowrc selects its target.'

list:
	@printf '%-20s %s\n' 'PACKAGE' 'GROUPS'
	@$(foreach package,$(PACKAGES),printf '%-20s %s\n' '$(package)' '$(strip $(foreach dir,$(STOW_DIRS),$(if $(wildcard $(dir)/$(package)/),$(dir))))';) :

check:
	@command -v "$(STOW)" >/dev/null 2>&1 || { printf '%s\n' 'GNU Stow is required.' >&2; exit 1; }

$(PACKAGES): check
	@set -eu; \
	for dir in $(STOW_DIRS); do \
	  [ -d "$$dir/$@" ] || continue; \
	  ( \
	    cd "$$dir"; \
	    target=$$($(stow_target)); \
	    printf '%s\n' "$(if $(DRY_RUN),simulate )$(STOW_ACTION_$(ACTION)): $$dir/$@ -> $$target"; \
	    if [ ! -d "$$target" ]; then \
	      if [ "$(ACTION)" = D ]; then \
	        printf '%s\n' 'Target does not exist; nothing to remove.'; \
	        exit 0; \
	      elif [ -n "$(DRY_RUN)" ]; then \
	        printf '%s\n' "Would create $$target and $(STOW_ACTION_$(ACTION)) $@."; \
	        exit 0; \
	      fi; \
	      mkdir -p "$$target"; \
	    fi; \
	    "$(STOW)" -$(ACTION) $(if $(DRY_RUN),-n) $(STOW_FLAGS_$@) "$@"; \
	  ); \
	done
