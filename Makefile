RECIPES = pancakes

MDS = $(RECIPES:=.md)
JSONS = $(RECIPES:=.json)
FJSONS = $(RECIPES:=.filtered.json)
HTMLS = $(RECIPES:=.html)
PDFS = $(RECIPES:=.pdf)

master: test.md
	pandoc --standalone --output master.json $<
	pandoc --standalone --output master.filtered.json --lua-filter recipe.lua $<

test: test.md master
	pandoc --standalone --output test.json $<
	php recipe.php < test.json > test.filtered.json
	pandoc --standalone --template recipe.html --to html5 --output test.html test.filtered.json
	diff -u master.filtered.json test.filtered.json

all: $(PDFS)

recipe.css: recipe.scss
	scss $< $@

%.json: %.md
	pandoc --standalone --output $@ $<

%.filtered.json: %.json recipe.php
	php recipe.php < $< > $@

%.html: %.filtered.json recipe.html
	pandoc --standalone --template recipe.html --to html5 --output $@ $<

%.pdf: %.html recipe.css
	prince --style recipe.css --output $@ $<

clean:
	rm -f $(HTMLS) $(PDFS) $(JSONS) $(FJSONS)

.PRECIOUS: %.html %.json %.filtered.json
