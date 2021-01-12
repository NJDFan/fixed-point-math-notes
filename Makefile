.phony: all

all: README.pdf

%.pdf: %.rst
	pandoc -o $@ $^
