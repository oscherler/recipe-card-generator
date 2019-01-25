ASSET_DIR = assets
RECIPE_DIR = recipes
IMAGES_DIR = images
TEMP_DIR = tmp
CARDS_DIR = cards

CSS_NAME = recipe
SCSS = $(ASSET_DIR)/$(CSS_NAME).scss
CSS = $(ASSET_DIR)/$(CSS_NAME).css
FILTER = $(ASSET_DIR)/recipe.php
CARD_TEMPLATE = $(ASSET_DIR)/recipe.card.html
IMAGE_PATH = ../$(IMAGES_DIR)

RECIPES = $(wildcard $(RECIPE_DIR)/*.md)
HTMLS = $(patsubst $(RECIPE_DIR)/%.md,$(TEMP_DIR)/%.html,$(RECIPES))
PDFS = $(patsubst $(RECIPE_DIR)/%.md,$(CARDS_DIR)/%.pdf,$(RECIPES))

all: cards

cards: $(PDFS)

$(CSS): $(SCSS)
	scss $< $@

$(TEMP_DIR)/%.html: $(RECIPE_DIR)/%.md $(FILTER) $(CARD_TEMPLATE)
	pandoc --standalone --section-divs --filter $(FILTER) --template $(CARD_TEMPLATE) --variable image_path:$(IMAGE_PATH) --to html5 --output $@ $<

$(CARDS_DIR)/%.pdf: $(TEMP_DIR)/%.html $(CSS)
	prince --style $(CSS) --output $@ $<
	./nup.bash $@

clean:
	rm -f $(HTMLS) $(PDFS)

.PRECIOUS: $(TEMP_DIR)/%.html

debug:
	$(info $(HTMLS_FOR_INDEX))
