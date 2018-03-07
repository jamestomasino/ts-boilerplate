WARNINGS := -Wall -Wextra
CFLAGS ?= -std=gnu99 -g $(WARNINGS)

# Overridable Config
SRC_DIR ?= src
DST_DIR ?= dest
NODE_MODULES ?= node_modules

ifeq ($(VERBOSE),1)
  MUTE :=
else
  MUTE := @
endif

# Reference to node binaries without installing globally
watch := $(NODE_MODULES)/.bin/watchthis
tsc := $(NODE_MODULES)/.bin/tsc
nodesass := $(NODE_MODULES)/.bin/node-sass
postbuild := $(NODE_MODULES)/.bin/postbuild

# Typescript source files & js transpiled files
SRC_TS_FILES != find $(SRC_DIR)/ts -name '*.ts'
DST_JS_FILES := $(SRC_TS_FILES:$(SRC_DIR)/ts/%.ts=$(DST_DIR)/js/%.js)

# Sass source files & css transpiled files
SRC_SASS_FILES != find src/scss/ -regex '[^_]*.scss'
DST_CSS_FILES := $(SRC_SASS_FILES:$(SRC_DIR)/scss/%.scss=$(DST_DIR)/css/%.css)

# HTML files & injected dest HTML
SRC_HTML_FILES != find $(SRC_DIR) -name '*.html'
DST_HTML_FILES := $(SRC_HTML_FILES:$(SRC_DIR)/%=$(DST_DIR)/%)

# Dependency checks
NPM != command -v npm 2> /dev/null
YARN != command -v yarn 2> /dev/null

# Macros
copy = cp $< $@
mkdir = $(MUTE)mkdir -p $(dir $@)

.PHONY: all clean watch install

all: node_modules $(DST_JS_FILES) $(DST_CSS_FILES) $(DST_HTML_FILES)

clean:
	rm -rf dest

watch:
	$(shell $(watch) -a ./$(SRC_DIR) make)

dest/js/%.js: src/ts/%.ts
	$(mkdir)
	$(tsc) $< --out $@

dest/css/%.css: src/scss/%.scss
	$(mkdir)
	$(nodesass) $< $@

dest/%.html: src/%.html
	$(mkdir)
	$(postbuild) -i $< -o $@ -g dest -c dest/css -j dest/js

install:
ifndef NPM
	$(error Missing dependency 'npm'. Please install and try again.)
endif
ifndef YARN
	$(error Missing dependency 'yarn'. Please install and try again.)
endif

node_modules: package.json yarn.lock
	yarn install --modules-folder ./$(NODE_MODULES)
	touch $(NODE_MODULES) # fixes watch bug if you manually ran yarn

