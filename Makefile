DIR_BUILD := build

include .env

# .env values are shell-quoted (so `. ./.env` works for release.sh and the
# just test recipe). Strip all double quotes for Make's use — metadata values
# must not contain literal " characters.
NAME       := $(subst ",,$(NAME))
EMAIL      := $(subst ",,$(EMAIL))
PHONE      := $(subst ",,$(PHONE))
GITHUB_URL := $(subst ",,$(GITHUB_URL))

OPT_VERSION := $(shell cat VERSION)

STR_NAME_SNAKE := $(shell echo '$(NAME)' | tr "[:upper:]" "[:lower:]" | tr " " "_")

JUSTFILE_VARIABLES := \
		"name=$(NAME)" \
		"email=$(EMAIL)" \
		"phone=$(PHONE)" \
		"github_url=$(GITHUB_URL)" \
		"version=$(OPT_VERSION)"

FILES_DEPS := VERSION .env Makefile

FILE_OUT_BASE := $(DIR_BUILD)/$(STR_NAME_SNAKE)_resume

.PHONY: all
all: $(FILE_OUT_BASE).html $(FILE_OUT_BASE).txt $(FILE_OUT_BASE).pdf;

$(FILE_OUT_BASE).%: $(DIR_BUILD)/resume.%
	cp '$<' '$@'

$(DIR_BUILD):
	mkdir $(DIR_BUILD)

build/%: % | $(DIR_BUILD)
	cp '$<' '$@'

WHICH_RESUME := resume.md
# WHICH_RESUME := resume-no-columns.md

build/resume.md: $(WHICH_RESUME) | $(DIR_BUILD)
	cp '$<' '$@'

# resume-builder emits <stem>.html beside its input; rename to the target.
define resume_builder_html
	resume-builder $(JUSTFILE_VARIABLES) $(1) "$<"
	mv "$<.html" "$@"
endef

build/%.pdf.html: build/%.md $(FILES_DEPS) | $(DIR_BUILD)
	$(call resume_builder_html,html-standalone)

build/%.html: build/%.md $(FILES_DEPS) | $(DIR_BUILD)
	$(call resume_builder_html,html-embedded)
	@test -d $(HOME)/eng2/site-linenisgreat/public \
	    && cp $@ $(HOME)/eng2/site-linenisgreat/public/resume.html \
	    || true

build/%.txt: build/%.md $(FILES_DEPS) | $(DIR_BUILD)
	resume-builder $(JUSTFILE_VARIABLES) txt "$<"
	mv "$<.txt" "$@"

build/%.docx: build/%.md $(FILES_DEPS) | $(DIR_BUILD)
	resume-builder $(JUSTFILE_VARIABLES) docx "$<"
	mv "$<.docx" "$@"

# One of: chrest, html-to-pdf
PDF_RENDERER ?= chrest
CMD_PDF_html-to-pdf = html-to-pdf "$<"
CMD_PDF_chrest      = chrest capture --format pdf --browser firefox \
                          --url "file://$(CURDIR)/$<" --no-headers --background

build/%.pdf: build/%.pdf.html $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_PDF_$(PDF_RENDERER)) > "$@"

.PHONY: clean
clean:
	-rm -rf '$(DIR_BUILD)'
