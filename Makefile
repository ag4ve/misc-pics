infiles = $(wildcard img/*.jpg) 
outfiles = $(subst img,thumbs, $(infiles))

.PHONY: all
all : $(outfiles)

thumbs/%.jpg: img/%.jpg
	mkdir -p thumbs
	# Guesswork here; probably update the command
	convert -thumbnail 200 $< $@

git:
	git add * img/* thumbs/*
	git commit -am "[Automatic] Makefile update."
