.PHONY: requirements etl clean lint jupyter

################################################################################
# COMMANDS                                                                     #
################################################################################

## Install Python Dependencies
requirements:
	pip install -U pip setuptools wheel
	pip install -r dev-requirements.txt

## Extract all test results
etl:
	./cli.py etl data/agora data/agora.csv.gz
	./cli.py etl data/bigg data/bigg.csv.gz
	./cli.py etl data/carveme data/carveme.csv.gz
	./cli.py etl data/ebrahim data/ebrahim.csv.gz
	./cli.py etl data/kbase data/kbase.csv.gz
	./cli.py etl data/optflux data/optflux.csv.gz
	./cli.py etl data/path data/path.csv.gz

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete
	rm -rf supplements_cache/*
	rm -rf supplements_files/*

## Generate all plots and supplementary material
plot: clean etl

	jupyter nbconvert --to notebook --ExecutePreprocessor.timeout=600 \
		--execute --inplace reports/clustering_metric_data.ipynb
	jupyter nbconvert --to notebook --ExecutePreprocessor.timeout=600 \
		--execute --inplace reports/clustering_score.ipynb
	Rscript scripts/plot_panel.R
	Rscript scripts/knit.R

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
