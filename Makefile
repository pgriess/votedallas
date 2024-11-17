SERVE_PORT?=8000
TEMPLATES_DIR=templates
BIN_DIR=bin
DOCS_DIR=docs
SITE_DIR=site

DOCS_CSS=$(shell find ${DOCS_DIR} -type f -name '*.css')
SITE_CSS=$(patsubst ${DOCS_DIR}/%.css,${SITE_DIR}/%.css,${DOCS_CSS})

DOCS_HTML=$(shell find ${DOCS_DIR} -type f -name '*.html+jinja2')
SITE_HTML=$(patsubst ${DOCS_DIR}/%.html+jinja2,${SITE_DIR}/%.html,${DOCS_HTML})

DOCS_PDF=$(shell find ${DOCS_DIR} -type f -name '*.pdf')
SITE_PDF=$(patsubst ${DOCS_DIR}/%.pdf,${SITE_DIR}/%.pdf,${DOCS_PDF})

TEMPLATES=$(shell find ${TEMPLATES_DIR} -type f -name '*.html+jinja2')

.PHONY: build clean serve

serve: build
	python -m http.server --directory ${SITE_DIR} -b 127.0.0.1 ${SERVE_PORT}

build: ${SITE_CSS} ${SITE_HTML} ${SITE_PDF}

clean:
	rm -fr ${SITE_DIR}

publish: build
	aws s3 sync --delete ${SITE_DIR}/ s3://www.votedallas.org/
	aws cloudfront create-invalidation --distribution-id=E2OSCXSVBFL0AQ --paths='/*'

${SITE_DIR}/%.css: ${DOCS_DIR}/%.css
	mkdir -p $(dir $@)
	cp $< $@

# TODO: We may need a mkdeps step here to pick up changes in the templates that
#       we depend on. See
#       https://jinja.palletsprojects.com/en/stable/api/#jinja2.meta.find_referenced_templates
#       for the Jinja2 API to do this sort of thing.
${SITE_DIR}/%.html: ${DOCS_DIR}/%.html+jinja2 ${TEMPLATES}
	mkdir -p $(dir $@)
	${BIN_DIR}/jinjar --docs_dir=${DOCS_DIR} --templates_dir=${TEMPLATES_DIR} $< $@

${SITE_DIR}/%.pdf: ${DOCS_DIR}/%.pdf
	mkdir -p $(dir $@)
	cp $< $@
