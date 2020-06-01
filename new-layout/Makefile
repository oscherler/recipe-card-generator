DOCKER = docker run --rm --volume "$(shell pwd):/data" recipe:latest
PANDOC = $(DOCKER) pandoc
PRINCE = $(DOCKER) prince
GS = $(DOCKER) gs

ASSET_DIR = assets
RECIPE_DIR = recipes
IMAGES_DIR = images
TEMP_DIR = tmp
CARDS_DIR = cards

CSS_NAME = recipe
SCSS = $(ASSET_DIR)/$(CSS_NAME).scss
CSS = $(ASSET_DIR)/$(CSS_NAME).css
INT_TEMPLATE = $(ASSET_DIR)/recipe.int.html
CARD_TEMPLATE = $(ASSET_DIR)/recipe.card.html
IMAGE_PATH = ../$(IMAGES_DIR)

RECIPES = $(wildcard $(RECIPE_DIR)/*.md)
HTMLS = $(patsubst $(RECIPE_DIR)/%.md,$(TEMP_DIR)/%.html,$(RECIPES))
PDFS = $(patsubst $(RECIPE_DIR)/%.md,$(CARDS_DIR)/%.pdf,$(RECIPES))

all: cards

cards: $(PDFS)

$(CSS): $(SCSS)
	scss $< $@

$(TEMP_DIR)/%.html: $(RECIPE_DIR)/%.md $(INT_TEMPLATE)
	$(PANDOC) --standalone --section-divs --template $(INT_TEMPLATE) --variable image_path:$(IMAGE_PATH) --to html5 --output $@ $<

$(CARDS_DIR)/%.pdf: $(TEMP_DIR)/%.html $(CSS)
	$(DOCKER) prince --style $(CSS) --output $@ $<

clean:
	rm -f $(HTMLS) $(PDFS)

.PRECIOUS: $(TEMP_DIR)/%.html

docker:
	docker image build --tag recipe .
