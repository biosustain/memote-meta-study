# -*- coding: utf-8 -*-

# Copyright 2017 Novo Nordisk Foundation Center for Biosustainability,
# Technical University of Denmark.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


"""Extract, transform, load."""


import json
import logging
from csv import QUOTE_NONNUMERIC
from glob import glob
from os.path import basename, join

import pandas as pd
from memote import ResultManager, ReportConfiguration
from tqdm import tqdm

__all__ = ("extract_transform_load",)


logger = logging.getLogger(__name__)


def transform(result, name, collection, biomass):
    tests = list()
    titles = list()
    metrics = list()
    numbers = list()
    for key, test in result["tests"].items():
        if isinstance(test["metric"], dict):
            for sub_key in test["metric"]:
                if key in biomass:
                    tests.append(f"{key}")
                    titles.append(f'{test["title"]}')
                else:
                    tests.append(f"{key}-{sub_key}")
                    titles.append(f'{test["title"]} - {sub_key}')
                metrics.append(test["metric"][sub_key])
                if test["format_type"] == "number":
                    numbers.append(test["data"][sub_key])
                elif test["format_type"] == "count":
                    numbers.append(len(test["data"][sub_key]))
                else:
                    numbers.append(float("nan"))
        else:
            tests.append(key)
            titles.append(test["title"])
            metrics.append(test["metric"])
            if test["format_type"] == "number":
                numbers.append(test["data"])
            elif test["format_type"] == "count":
                try:
                    numbers.append(len(test["data"]))
                except TypeError:
                    numbers.append(float("nan"))
            else:
                numbers.append(float("nan"))
    return pd.DataFrame({
        "test": tests,
        "title": titles,
        "metric": metrics,
        "numeric": numbers,
        "model": name,
        "collection": collection
    })


def extract_transform_load(path, output, collection):
    # Extract all the individual memote results found in the path.
    files = sorted(glob(join(path, "*.json*")))
    manager = ResultManager()
    config = ReportConfiguration.load()
    biomass = frozenset(config["cards"]["test_biomass"]["cases"])
    tables = []
    for filename in tqdm(files, desc="Memote Results"):
        # Extract the memote result.
        try:
            result = manager.load(filename)
        except json.JSONDecodeError:
            logger.warning("Could not load result %r.", filename)
            continue
        # Transform the results into one large table.
        tables.append(transform(
            result, basename(filename).split(".")[0], collection, biomass))
    metrics = pd.concat(tables, ignore_index=True)
    # Load the results into an intermediate CSV file.
    logger.info("Writing results to '%s'.", output)
    metrics.to_csv(output, index=False, quoting=QUOTE_NONNUMERIC)
