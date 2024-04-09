
DIR_BUILD := build

CMD_CHROME := /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome

OPT_NAME := $(shell cat NAME)
OPT_PHONE := $(shell cat PHONE)
OPT_EMAIL := $(shell cat EMAIL)
OPT_GITHUB_URL := $(shell cat GITHUB_URL)
OPT_VERSION := $(shell cat VERSION)
OPT_DATE := $(shell date -u +"%Y-%m")

STR_NAME_SNAKE := $(shell cat NAME | tr "[:upper:]" "[:lower:]" | tr " " "_")

CMD_PANDOC := \
	pandoc -f markdown \
	--section-div \
	--embed-resources --standalone \
	--shift-heading-level-by=1 \
	-c build/style.css \
	-V 'version=$(OPT_VERSION)' \
	-V 'email=$(OPT_EMAIL)' \
	-V 'phone=$(OPT_PHONE)' \
	-V 'name=$(OPT_NAME)' \
	-V 'build-date=$(OPT_DATE)' \
	-V 'github-url=$(OPT_GITHUB_URL)' \
	--metadata "title=$(OPT_NAME)'s Resume"

# TODO fix build rule issue with variables above

OPT_PANDOC_TEMPLATE_HTML := --template '$(shell pwd)/build/template.html'

FILES_DEPS := VERSION build/style.css Makefile build/template.html

STR_NAME_SNAKE := $(shell cat NAME | tr "[:upper:]" "[:lower:]" | tr " " "_")
FILE_OUT_BASE := $(DIR_BUILD)/$(STR_NAME_SNAKE)_resume

.PHONY: all
all: $(FILE_OUT_BASE).html $(FILE_OUT_BASE).txt $(FILE_OUT_BASE).pdf;

$(FILE_OUT_BASE).%: $(DIR_BUILD)/resume.%
	cp '$<' '$@'

$(DIR_BUILD):
	mkdir $(DIR_BUILD)

build/%: % | $(DIR_BUILD)
	cp '$<' '$@'

build/resume.md: resume-no-columns.md | $(DIR_BUILD)
	cp '$<' '$@'

# build/style.css: style.scss | $(DIR_BUILD)
# 	nix-shell -p sass --run "sass '$<' '$@'"

build/%.html: build/%.md $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_PANDOC) \
		$(OPT_PANDOC_TEMPLATE_HTML) \
		'$<' -o '$(patsubst %.md,%.html,$<)'

build/NAME.txt: Makefile
	figlet -c -fsmslant '$(OPT_NAME)' > '$@'

build/%.txt: build/%.md build/NAME.txt build/template.txt build/filter-plain.lua $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_PANDOC) \
		--template build/template.txt \
		--reference-links \
		--columns 80 \
		--lua-filter build/filter-plain.lua \
		--to markdown \
		'$<' -o '$(patsubst %.md,%.txt,$<)'

CMD_GREP_CLEAN_CHROME_OUTPUT := grep -v 'AttributionReportingCrossAppWeb'

build/%.pdf: build/%.html $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_CHROME) \
		--headless \
		--disable-gpu \
		'--print-to-pdf=$(patsubst %.html,%.pdf,$<)' \
		--no-pdf-header-footer \
		--print-to-pdf-no-header \
		'$<' 2>&1 | $(CMD_GREP_CLEAN_CHROME_OUTPUT)

.PHONY: clean
clean:
	-rm -rf '$(DIR_BUILD)'

.PHONY: install
install:
	brew bundle install

