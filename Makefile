DOCKER = docker run --rm --volume "$(shell pwd):/data" recipe:latest
PANDOC = $(DOCKER) pandoc
PRINCE = $(DOCKER) prince
GS = $(DOCKER) gs
PYTHON = venv/bin/python
PIP = venv/bin/pip

ASSET_DIR = assets
RECIPE_DIR = recipes
IMAGES_DIR = images
TEMP_DIR = tmp
CARDS_DIR = cards

CSS_NAME = recipe-side
SCSS = $(ASSET_DIR)/$(CSS_NAME).scss
CSS = $(ASSET_DIR)/$(CSS_NAME).css
FILTER = $(ASSET_DIR)/recipe.php
INT_TEMPLATE = $(ASSET_DIR)/recipe.int.html
IMAGE_PATH = ../$(IMAGES_DIR)

RECIPES = $(wildcard $(RECIPE_DIR)/*.md)
HTMLS = $(patsubst $(RECIPE_DIR)/%.md,$(TEMP_DIR)/%.html,$(RECIPES))
PDFS = $(patsubst $(RECIPE_DIR)/%.md,$(CARDS_DIR)/%.pdf,$(RECIPES))

all: cards

cards: $(PDFS)

$(CSS): $(SCSS)
	scss $< $@

$(TEMP_DIR)/%.int.html: $(RECIPE_DIR)/%.md $(INT_TEMPLATE)
	$(PANDOC) --standalone --section-divs --template $(INT_TEMPLATE) --variable image_path:$(IMAGE_PATH) --to html5 --output $@ $<

$(TEMP_DIR)/%.html: $(TEMP_DIR)/%.int.html $(ASSET_DIR)/intermediate.py
	$(PYTHON) $(ASSET_DIR)/intermediate.py $< $@

$(CARDS_DIR)/%.pdf: $(TEMP_DIR)/%.html $(CSS)
	$(PRINCE) --style $(CSS) --output $@ $<
	#./nup.bash $@

clean:
	rm -f $(HTMLS) $(PDFS)

.PRECIOUS: $(TEMP_DIR)/%.int.html $(TEMP_DIR)/%.html

debug:
	$(info $(HTMLS_FOR_INDEX))

docker:
	docker image build --tag recipe .

venv:
	python3 -mvenv venv
	$(PIP) install -r requirements.txt
