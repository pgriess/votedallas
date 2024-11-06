DOCS_DIR=docs
SITE_DIR=site

DOCS_FILES=$(shell find ${DOCS_DIR} -type f)

.PHONY: deploy serve

${SITE_DIR}/sitemap.xml: mkdocs.yml ${DOCS_FILES}
	mkdocs build

deploy: ${SITE_DIR}/sitemap.xml
	aws s3 sync --delete site/ s3://www.votedallas.org/

serve:
	mkdocs serve
