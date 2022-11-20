all:
	mdbook build
	rm -rf docs
	mv book docs

.PHONY: all
