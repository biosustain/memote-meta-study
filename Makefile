.PHONY: requirements download test clean lint jupyter

################################################################################
# GLOBALS                                                                      #
################################################################################

PYTHON_INTERPRETER = python3

################################################################################
# COMMANDS                                                                     #
################################################################################

## Install Python Dependencies
requirements:
	pip install -U pip setuptools wheel pipenv
	pipenv install

## Download all metabolic models
download:
	./cli.py bigg download
	./cli.py uminho download
	git fetch https://github.com/opencobra/m_model_collection.git master
	git subtree pull --prefix models/mmodel https://github.com/opencobra/m_model_collection.git master --squash
	git fetch https://github.com/cdanielmachado/embl_gems.git master
	git subtree pull --prefix models/carveme https://github.com/cdanielmachado/embl_gems.git master --squash

## Run memote on all models
test:
	./cli.py bigg test
	./cli.py uminho test
	./cli.py mmodel test

## Extract all test results
etl:
	./cli.py etl data/bigg data/bigg.csv.gz
	./cli.py etl data/uminho data/uminho.csv.gz
	./cli.py etl data/mmodel/sbml3 data/mmodel.csv.gz
	./cli.py etl data/AGORA/CurrentVersion/AGORA-1.03_sbml/sbml data/agora.csv.gz
	./cli.py etl data/embl_gems data/embl_gems.csv.gz
	./cli.py etl data/BioModels_Database-r27_p2m-whole_genome_metabolism data/path2models.csv.gz
	./cli.py etl data/seed data/seed.csv.gz

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf supplements_cache/*
	rm -rf supplements_files/*

## Lint using flake8
lint:
	flake8 src

## Install Jupyter notebook extensions and widgets
jupyter:
	jupyter contrib nbextension install --sys-prefix
	jupyter nbextensions_configurator enable
	jupyter nbextension enable --py --sys-prefix widgetsnbextension

################################################################################
# Self Documenting Commands                                                    #
################################################################################

.DEFAULT_GOAL := show-help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: show-help
show-help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
