
BREW_BUNDLE_CMD := ${brew bundle exec -- }

all: build open

build:
	${BREW_BUNDLE_CMD} pdflatex -interaction=nonstopmode resume.latex

open:
	open resume.pdf

install:
	brew bundle install

