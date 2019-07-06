
BREW_BUNDLE_CMD := ${brew bundle exec -- }

all: build

build:
	${BREW_BUNDLE_CMD} pdflatex resume.latex

install:
	brew bundle install

