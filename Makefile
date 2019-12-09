
BREW_BUNDLE_CMD := brew bundle exec --

DIR_BUILD := build

FILES_RAW_LATEX_CLASS := $(wildcard *.cls)
FILES_RAW_LATEX := $(wildcard *.latex)

FILES_BUILD_LATEX := $(addprefix $(DIR_BUILD)/,$(FILES_RAW_LATEX))
FILES_BUILD_LATEX_PDF := $(FILES_BUILD_LATEX:.latex=.pdf)

all: $(FILES_BUILD_LATEX_PDF)

$(DIR_BUILD):
	mkdir $(DIR_BUILD)

$(FILES_BUILD_LATEX): $(FILES_RAW_LATEX) | $(DIR_BUILD)
	cp $(notdir $@) $(DIR_BUILD)

$(FILES_BUILD_LATEX_PDF): $(FILES_BUILD_LATEX) $(FILES_RAW_LATEX_CLASS) | $(DIR_BUILD)
	${BREW_BUNDLE_CMD} pdflatex \
		-halt-on-error \
		-interaction=batchmode \
		-output-directory=$(DIR_BUILD) \
		$(notdir $(@:.pdf=.latex))

.PHONY: open
open: $(FILES_BUILD_LATEX_PDF)
	open $(FILES_BUILD_LATEX_PDF)

.PHONY: clean
clean:
	-rm -rf $(DIR_BUILD)

.PHONY: install
install:
	brew bundle install

