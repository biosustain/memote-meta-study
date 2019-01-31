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
import os
from csv import QUOTE_NONNUMERIC
from glob import glob
from os.path import basename, join

import pandas as pd
from memote import ResultManager, ReportConfiguration
from tqdm import tqdm

__all__ = ("extract_transform_load",)


logger = logging.getLogger(__name__)


def transform(result, name, collection, biomass, sections):
    tests = []
    titles = []
    metrics = []
    numbers = []
    section = []
    for key, test in result["tests"].items():
        if isinstance(test["metric"], dict):
            for sub_key in test["metric"]:
                if key in biomass:
                    tests.append(f"{key}")
                    titles.append(f'{test["title"]}')
                else:
                    tests.append(f"{key}-{sub_key}")
                    titles.append(f'{test["title"]} - {sub_key}')
                section.append(sections[key])
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
            section.append(sections[key])
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
        "section": section,
        "metric": metrics,
        "numeric": numbers,
        "model": name,
        "collection": collection
    })


def extract_transform_load(path, output, collection, file_format=".json.gz"):
    # Extract all the individual memote results found in the path.

    files = sorted(glob(join(path, "*.json*")))
    manager = ResultManager()
    config = ReportConfiguration.load()
    # Generate a list of parametrized tests whose cases will become
    # indistinguishable.
    biomass = frozenset(
        config["cards"]["test_biomass"]["cases"] + ["test_gam_in_biomass"]
    )
    # Map test cases to sections.
    sections = {
        t: sec for sec, body in config["cards"]["scored"]["sections"].items()
        for t in body["cases"]
    }
    del config["cards"]["scored"]
    sections.update({
        t: sec for sec, body in config["cards"].items() for t in body["cases"]
    })
    files = []
    for dirpath, dirnames, filenames in os.walk(path):
        for filename in filenames:
            if filename.endswith(file_format):
                files.append(join(dirpath, filename))
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
            result, basename(filename).split(".json")[0], collection,
            biomass, sections))
    metrics = pd.concat(tables, ignore_index=True)
    # Load the results into an intermediate CSV file.
    logger.info("Writing results to '%s'.", output)
    metrics.to_csv(output, index=False, quoting=QUOTE_NONNUMERIC)
