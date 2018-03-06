.PHONY: all clean watch install

# Reference to node binaries without installing globally
watch := node_modules/.bin/watch
tsc := node_modules/.bin/tsc
nodesass := node_modules/.bin/node-sass
postbuild := node_modules/.bin/postbuild

# Typescript source files & js transpiled files
src_ts_files := $(shell find src/ts -name '*.ts')
dest_js_files := $(patsubst %ts,%js,$(patsubst src/ts/%,dest/js/%,$(src_ts_files)))

# Sass source files & css transpiled files
src_sass_files := $(shell find src/scss/ -regex '[^_]*.scss')
dest_css_files := $(patsubst %scss,%css,$(patsubst src/scss/%,dest/css/%,$(src_sass_files)))

# HTML files & injected dest HTML
src_html_files := $(shell find src -name '*.html')
dest_html_files := $(patsubst src/%,dest/%,$(src_html_files))

# Dependency checks
NPM := $(shell command -v npm 2> /dev/null)
YARN := $(shell command -v yarn 2> /dev/null)

mkdir = @mkdir -p $(dir $@)

all: node_modules $(dest_js_files) $(dest_css_files) $(dest_html_files)

clean:
	rm -rf dest

watch:
	$(watch) make src/

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
	yarn install
