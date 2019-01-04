all: pancakes.pdf

%.html: %.md recipe.lua recipe.html
	pandoc --standalone --lua-filter recipe.lua --template recipe.html --to html5 --output $@ $<

%.pdf: %.html recipe.css
	prince --style recipe.css --output $@ $<

clean:
	rm -f pancakes.html pancakes.pdf

.PRECIOUS: %.html
