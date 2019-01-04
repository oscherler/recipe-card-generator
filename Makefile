RECIPES = pancakes

MDS = $(RECIPES:=.md)
HTMLS = $(RECIPES:=.html)
PDFS = $(RECIPES:=.pdf)

all: $(PDFS)

%.html: %.md recipe.lua recipe.html
	pandoc --standalone --lua-filter recipe.lua --template recipe.html --to html5 --output $@ $<

%.pdf: %.html recipe.css
	prince --style recipe.css --output $@ $<

clean:
	rm -f $(HTMLS) $(PDFS)

.PRECIOUS: %.html
