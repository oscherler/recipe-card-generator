all: pancakes.pdf

%.html: %.md recipe.lua recipe.html
	pandoc --standalone --lua-filter recipe.lua --template recipe.html --to html5 --output $@ $<

%.pdf: %.html recipe.css
	pandoc --css recipe.css --pdf-engine prince --output $@ $<

clean:
	rm -f pancakes.html pancakes.pdf

.PRECIOUS: %.html
