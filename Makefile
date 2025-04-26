SERVE_PORT?=8000
TEMPLATES_DIR=templates
BIN_DIR=bin
DEPS_DIR=.deps
DOCS_DIR=docs
SITE_DIR=site
AWS_S3_BUCKET?=www.votedallas.org
AWS_CF_DISTRIBUTION?=E2OSCXSVBFL0AQ

DOCS_CSS=$(shell find ${DOCS_DIR} -type f -name '*.css')
SITE_CSS=$(patsubst ${DOCS_DIR}/%.css,${SITE_DIR}/%.css,${DOCS_CSS})

DOCS_HTML=$(shell find ${DOCS_DIR} -type f -name '*.html+jinja2')
SITE_HTML=$(patsubst ${DOCS_DIR}/%.html+jinja2,${SITE_DIR}/%.html,${DOCS_HTML})

DOCS_PDF=$(shell find ${DOCS_DIR} -type f -name '*.pdf')
SITE_PDF=$(patsubst ${DOCS_DIR}/%.pdf,${SITE_DIR}/%.pdf,${DOCS_PDF})

.PHONY: build clean serve publish
.DEFAULT_GOAL := serve

# Source all dependency definitions
#
# We use the '-' prefix for the 'include' directive here so that it silently
# ignores files that it could not find. This happens if there are no dependency
# files (e.g. after a clean or on a fresh checkout).
-include $(subst ${DOCS_DIR}/,${DEPS_DIR}/,${DOCS_HTML})

# Render templates
#
# Note that as a side-effect of rendering, we emit a GNU Make formatted
# dependency file into the the directory specified by --gnumake_deps_dir. We do
# this as a side-effect rather than defining a separate step because on a clean
# build (no dependency files) we'll be doing a full re-build anyway and so will
# hit this case. After that, we can rely on the dependency files to trigger a
# re-build and thus get here anyway.
#
# See https://www.gnu.org/software/make/manual/html_node/Automatic-Prerequisites.html.
${SITE_DIR}/%.html: ${DOCS_DIR}/%.html+jinja2
	mkdir -p $(dir $(patsubst ${DOCS_DIR}/%.html+jinja2,${DEPS_DIR}/%.html+jinja2,$<))
	${BIN_DIR}/jinjar \
		--docs_dir=${DOCS_DIR} \
		--templates_dir=${TEMPLATES_DIR} \
		--gnumake_deps_file=$(patsubst ${DOCS_DIR}/%.html+jinja2,${DEPS_DIR}/%.html+jinja2,$<) \
		-t source_relative_path=$(shell basename $(shell dirname $(shell dirname $(patsubst ${DOCS_DIR}/%.html+jinja2,%.html+jinja2,$<)))) \
		$< $@

${SITE_DIR}/%: ${DOCS_DIR}/%
	mkdir -p $(dir $@)
	cp $< $@

serve: build
	python -m http.server --directory ${SITE_DIR} -b 127.0.0.1 ${SERVE_PORT}

build: ${SITE_CSS} ${SITE_HTML} ${SITE_PDF}

clean:
	rm -fr ${DEPS_DIR} ${SITE_DIR}

publish: build
	aws s3 sync --delete ${SITE_DIR}/ s3://${AWS_S3_BUCKET}/
	aws cloudfront create-invalidation --distribution-id=${AWS_CF_DISTRIBUTION} --paths='/*'
