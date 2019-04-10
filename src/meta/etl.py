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
from os.path import basename, join

import pandas as pd
from memote import ResultManager, ReportConfiguration
from tqdm import tqdm

__all__ = ("extract_transform_load",)

logger = logging.getLogger(__name__)


def transform_candidate_irreversible_reactions(result, element):
    # Test case errored.
    if element is None:
        return
    if (len(element[1]) + len(element[2]) + len(element[3])) == len(
        result["tests"]["test_find_pure_metabolic_reactions"]["data"]
    ):
        return float("nan")
    else:
        return len(element[0])


SPECIAL_PERCENT = {
    "test_find_reactions_with_identical_genes":
        lambda r, x: len(x),
    "test_find_reactions_with_partially_identical_annotations":
        lambda r, x: len(x),
    "test_find_candidate_irreversible_reactions":
        transform_candidate_irreversible_reactions,
}


def transform_element(result, element, format_type, case=""):
    if format_type == "number":
        return element
    elif format_type == "count":
        if isinstance(element, list):
            return len(element)
        else:
            logger.debug(case)
            logger.debug("Format 'count' of element %r.", element)
            return element
    elif format_type == "percent":
        if case in SPECIAL_PERCENT:
            return SPECIAL_PERCENT[case](result, element)
        elif isinstance(element, list):
            return len(element)
        else:
            return element
    elif format_type == "raw":
        if isinstance(element, bool):
            return int(element)
        elif isinstance(element, str):
            # Return negative number to denote that string was there but it's
            # not a meaningful value.
            return -1.0
        elif isinstance(element, int):
            return element
        else:
            logger.debug(case)
            logger.debug("Raw element %r.", element)
    else:
        return float("nan")


def transform(result, name, biomass, sections):
    tests = []
    titles = []
    metrics = []
    numbers = []
    section = []
    status = []
    times = []
    for key, test in result["tests"].items():
        if isinstance(test["metric"], dict):
            for sub_key in test["result"]:
                test_name = f"{key}-{sub_key}"
                if key in biomass:
                    # We do not distinguish the different biomass reactions.
                    tests.append(f"{key}")
                    titles.append(f'{test["title"]}')
                else:
                    tests.append(test_name)
                    titles.append(f'{test["title"]} - {sub_key}')
                section.append(sections[key])
                metrics.append(test["metric"].get(sub_key))
                numbers.append(transform_element(
                    result, test["data"].get(sub_key), test["format_type"]))
                times.append(test["duration"].get(sub_key))
                status.append(test["result"].get(sub_key))
        else:
            tests.append(key)
            titles.append(test["title"])
            section.append(sections[key])
            metrics.append(test["metric"])
            numbers.append(transform_element(
                result, test["data"], test["format_type"], case=key))
            times.append(test["duration"])
            status.append(test["result"])
    return pd.DataFrame({
        "test": tests,
        "title": titles,
        "section": section,
        "metric": metrics,
        "numeric": numbers,
        "model": name,
        "time": times,
        "status": status
    })


def extract_transform_load(path, output, file_format):
    # Extract all the individual memote results found in the path.

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
            result, basename(filename).split(".json")[0], biomass, sections))
    if len(tables) == 0:
        logger.info("No data files. Nothing to do.")
        return
    metrics = pd.concat(tables, ignore_index=True)
    # Load the results into an intermediate CSV file.
    logger.info("Writing results to '%s'.", output)
    if output.endswith(".gz"):
        metrics.to_csv(output, index=False, quoting=QUOTE_NONNUMERIC,
                       compression="gzip")
    else:
        metrics.to_csv(output, index=False, quoting=QUOTE_NONNUMERIC)
