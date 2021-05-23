
DIR_BUILD := build

CMD_CHROME := /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome

OPT_NAME := $(shell cat NAME)
OPT_PHONE := $(shell cat PHONE)
OPT_EMAIL := $(shell cat EMAIL)
OPT_VERSION := $(shell cat VERSION)
OPT_DATE := $(shell date -u +"%Y-%m")

CMD_PANDOC := \
	pandoc -f markdown \
	--section-div --self-contained \
	--shift-heading-level-by=1 \
	-c build/style.css \
	-V 'version=$(OPT_VERSION)' \
	-V 'email=$(OPT_EMAIL)' \
	-V 'phone=$(OPT_PHONE)' \
	-V 'name=$(OPT_NAME)' \
	-V 'build-date=$(OPT_DATE)' \
	--metadata "title=$(OPT_NAME)'s Resume"

# TODO fix build rule issue with variables above

OPT_PANDOC_TEMPLATE_HTML := --template '$(shell pwd)/build/template.html'

FILES_DEPS := VERSION build/style.css Makefile build/template.html

.PHONY: all
all: $(patsubst %.latex,build/%.pdf,$(wildcard *.latex));

$(DIR_BUILD):
	mkdir $(DIR_BUILD)

build/%: % | $(DIR_BUILD)
	cp '$<' '$(DIR_BUILD)'

build/%.html: build/%.md $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_PANDOC) \
		$(OPT_PANDOC_TEMPLATE_HTML) \
		'$<' -o '$(patsubst %.md,%.html,$<)'

build/%.txt: build/%.md template.txt filter-plain.lua $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_PANDOC) \
		--template template.txt \
		-t filter-plain.lua \
		'$<' -o '$(patsubst %.md,%.txt,$<)'

build/%.pdf: build/%.html $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_CHROME) --headless --disable-gpu \
		'--print-to-pdf=$(patsubst %.html,%.pdf,$<)' --print-to-pdf-no-header \
		'$<'

.PHONY: clean
clean:
	-rm -rf '$(DIR_BUILD)'

.PHONY: install
install:
	brew bundle install

