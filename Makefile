RECIPES = pancakes

MDS = $(RECIPES:=.md)
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

%.html: %.md recipe.lua recipe.html
	pandoc --standalone --lua-filter recipe.lua --template recipe.html --to html5 --output $@ $<

%.pdf: %.html recipe.css
	prince --style recipe.css --output $@ $<

clean:
	rm -f $(HTMLS) $(PDFS)

.PRECIOUS: %.html %.json %.filtered.json
