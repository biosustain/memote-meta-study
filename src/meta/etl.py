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


def transform_candidate_irreversible_reactions(result, data, metric):
    """Transform the specific test result."""
    # TODO (Moritz Beber): This is a temporary workaround until the test
    #  `test_find_candidate_irreversible_reactions` is fixed.
    if data is None:
        return None, None
    if len(data[0]) == 0:
        return None, None
    num_irrev = sum(1 for _, i in data[0] if abs(float(i)) >= 7.0)
    return num_irrev, num_irrev / len(data[0])


def transform_find_reactions_with_identical_genes(result, data, metric):
    """Transform the specific test result."""
    # TODO (Moritz Beber): This is a temporary workaround until the test
    #  `test_find_reactions_with_identical_genes` is fixed.
    if data is None:
        return None, None
    if len(data) == 0:
        return None, None
    # This was the original bug, reactions with no GPR were inserted with the
    # empty string as key.
    if "" in data:
        del data[""]
    dupes = set()
    for gpr, rxns in data.items():
        dupes.update(rxns)
    return (
        len(dupes),
        len(dupes) / len(result["tests"]["test_reactions_presence"]["data"]),
    )


SPECIAL_PERCENT = {
    "test_find_reactions_with_partially_identical_annotations": lambda result, data, metric: (
        len(data),
        metric,
    ),
    "test_find_candidate_irreversible_reactions": transform_candidate_irreversible_reactions,
    "test_find_reactions_with_identical_genes": transform_find_reactions_with_identical_genes,
}


def transform_element(result, data, metric, format_type, case=""):
    if format_type == "number":
        return data, metric
    elif format_type == "count":
        if isinstance(data, list):
            return len(data), metric
        else:
            logger.debug(case)
            logger.debug("Format 'count' of element %r.", data)
            return data, metric
    elif format_type == "percent":
        if case in SPECIAL_PERCENT:
            return SPECIAL_PERCENT[case](result, data, metric)
        elif isinstance(data, list):
            return len(data), metric
        else:
            return data, metric
    elif format_type == "raw":
        if isinstance(data, bool):
            return int(data), metric
        elif isinstance(data, str):
            # Return negative number to denote that string was there but it's
            # not a meaningful value.
            return -1.0, metric
        elif isinstance(data, int):
            return data, metric
        else:
            logger.debug(case)
            logger.debug("Format 'raw' of element %r.", data)
            return None, None
    else:
        logger.warning(case)
        logger.warning("Format %r of element %r.", format_type, data)
        return None, metric


def transform(config, result, name, biomass, sections, scored_tests):
    logger.debug(name)
    tests = []
    titles = []
    metrics = []
    numbers = []
    section = []
    status = []
    times = []
    scores = []
    weights = []
    for key, test in result["tests"].items():
        factor = config["weights"].get(key, 1.0)
        if isinstance(test["result"], dict):
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
                data = test["data"].get(sub_key)
                metric = test["metric"].get(sub_key)
                number, metric = transform_element(
                    result, data, metric, test["format_type"], case=test_name
                )
                numbers.append(number)
                metrics.append(metric)
                times.append(test["duration"].get(sub_key))
                status.append(test["result"].get(sub_key))
                # Compute scoring.
                if key not in scored_tests:
                    scores.append(None)
                    weights.append(None)
                else:
                    score = None if metric is None else 1.0 - metric
                    scores.append(score)
                    weights.append(factor)

        else:
            tests.append(key)
            titles.append(test["title"])
            section.append(sections[key])
            data = test["data"]
            metric = test["metric"]
            number, metric = transform_element(
                result, data, metric, test["format_type"], case=key
            )
            numbers.append(number)
            metrics.append(metric)
            times.append(test["duration"])
            status.append(test["result"])
            # Compute scoring.
            if key not in scored_tests:
                scores.append(None)
                weights.append(None)
            else:
                score = None if metric is None else 1.0 - metric
                scores.append(score)
                weights.append(factor)
    return pd.DataFrame(
        {
            "test": tests,
            "title": titles,
            "section": section,
            "metric": metrics,
            "numeric": numbers,
            "model": name,
            "time": times,
            "score": scores,
            "weight": weights,
            "status": status,
        }
    )


def extract_transform_load(path, output, file_format):
    # Extract all the individual memote results found in the path.

    manager = ResultManager()
    config = ReportConfiguration.load()
    # Generate a list of parametrized tests whose cases will become
    # indistinguishable.
    biomass = frozenset(
        config["cards"]["test_biomass"]["cases"] + ["test_gam_in_biomass"]
    )
    # Collect scored tests.
    scored_tests = frozenset(
        t
        for _, s in config["cards"]["scored"]["sections"].items()
        for t in s["cases"]
    )
    # Map test cases to sections.
    sections = {
        t: sec
        for sec, body in config["cards"]["scored"]["sections"].items()
        for t in body["cases"]
    }
    del config["cards"]["scored"]
    sections.update(
        {t: sec for sec, body in config["cards"].items() for t in body["cases"]}
    )
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
        tables.append(
            transform(
                config,
                result,
                basename(filename).split(".json")[0],
                biomass,
                sections,
                scored_tests,
            )
        )
    if len(tables) == 0:
        logger.info("No data files. Nothing to do.")
        return
    metrics = pd.concat(tables, ignore_index=True)
    # Load the results into an intermediate CSV file.
    logger.info("Writing results to '%s'.", output)
    if output.endswith(".gz"):
        metrics.to_csv(
            output, index=False, quoting=QUOTE_NONNUMERIC, compression="gzip"
        )
    else:
        metrics.to_csv(output, index=False, quoting=QUOTE_NONNUMERIC)
