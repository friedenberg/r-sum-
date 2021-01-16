
CMD_BREW_BUNDLE := brew bundle exec --no-upgrade --

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
	${CMD_BREW_BUNDLE} pdflatex \
		-halt-on-error \
		-file-line-error \
		-interaction=batchmode \
		'-output-directory=$(DIR_BUILD)' \
		'$<'

.PHONY: open/%.pdf
open/%.pdf: build/%.pdf
	open -gF '$<'

.PHONY: clean
clean:
	-rm -rf '$(DIR_BUILD)'

.PHONY: install
install:
	brew bundle install

