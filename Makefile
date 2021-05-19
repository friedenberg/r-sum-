
DIR_BUILD := build

CMD_CHROME := /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome

CMD_PANDOC := \
	pandoc -f markdown \
	--section-div --self-contained \
	--shift-heading-level-by=1 \
	-c build/style.css \
	-V 'version=$(shell cat VERSION)' \
	-V 'email=$(shell cat EMAIL)' \
	-V 'phone=$(shell cat PHONE)' \
	-V 'name=$(shell cat NAME)' \
	--title "$(shell cat NAME)'s Resume" \
	-V 'build-date=$(shell date -u +"%Y-%m")'

# TODO fix build rule issue with variables above

OPT_PANDOC_TEMPLATE_HTML := --template '$(shell pwd)/build/template.html'

FILES_DEPS := VERSION build/style.css Makefile build/template.html

.PHONY: all
all: $(patsubst %.latex,build/%.pdf,$(wildcard *.latex));

$(DIR_BUILD):
	mkdir $(DIR_BUILD)

build/%.cls: %.cls | $(DIR_BUILD)
	cp '$<' '$(DIR_BUILD)'

build/%.latex: %.latex | $(DIR_BUILD)
	cp '$<' '$(DIR_BUILD)'

build/%.md: %.md | $(DIR_BUILD)
	cp '$<' '$(DIR_BUILD)'

build/%.html: %.html | $(DIR_BUILD)
	cp '$<' '$(DIR_BUILD)'

build/%.css: %.css | $(DIR_BUILD)
	cp '$<' '$(DIR_BUILD)'

build/%_out.md: build/%.md $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_PANDOC) '$<' -o '$(patsubst %.md,%_out.md,$<)'

build/%.pdf: build/%.html $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_CHROME) --headless --disable-gpu '--print-to-pdf=$(patsubst %.html,%.pdf,$<)' --print-to-pdf-no-header '$<'

build/%.html: build/%.md $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_PANDOC) $(OPT_PANDOC_TEMPLATE_HTML) '$<' -o '$(patsubst %.md,%.html,$<)'

build/%.latex: build/%.md $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_PANDOC) -t latex '$<' -o '$(patsubst %.md,%.latex,$<)'

# TODO
build/%.txt: build/%.md $(FILES_DEPS) | $(DIR_BUILD)
	$(CMD_PANDOC) '$<' -o '$(patsubst %.md,%.txt,$<)'

.PHONY: open/%.pdf
open/%.pdf: build/%.pdf
	open -F '$<'

.PHONY: clean
clean:
	-rm -rf '$(DIR_BUILD)'

.PHONY: install
install:
	brew bundle install

