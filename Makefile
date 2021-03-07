
DIR_BUILD := build/

.PHONY: all
all: $(patsubst %.latex,build/%.pdf,$(wildcard *.latex));

$(DIR_BUILD):
	mkdir $(DIR_BUILD)

build/%.cls: %.cls | $(DIR_BUILD)
	cp '$<' '$(DIR_BUILD)'

build/%.latex: %.latex | $(DIR_BUILD)
	cp '$<' '$(DIR_BUILD)'

build/%.pdf: build/%.latex build/*.cls VERSION | $(DIR_BUILD)
	date -u +"%Y-%m" > "$(DIR_BUILD)/DATE_LAST_UPDATED"
	pdflatex \
		-halt-on-error \
		-file-line-error \
		-interaction=batchmode \
		'-output-directory=$(DIR_BUILD)' \
		'$<'

.PHONY: open/%.pdf
open/%.pdf: build/%.pdf
	open -F '$<'

.PHONY: clean
clean:
	-rm -rf '$(DIR_BUILD)'

.PHONY: install
install:
	brew bundle install

