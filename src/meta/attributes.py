# Copyright 2019 Novo Nordisk Foundation Center for Biosustainability,
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


import logging
import multiprocessing
import os
import os.path as osp

import click
import click_log
from cobra.io import read_sbml_model
from pandas import DataFrame
from tqdm import tqdm


logger = logging.getLogger()
click_log.basic_config(logger)


def find_models(base, models, file_format=".xml.gz"):
    for dirpath, dirnames, filenames in os.walk(base):
        logger.debug(dirpath)
        # Continue walking the directories if there are no model files in the
        # current directory.
        for name in filenames:
            if name.endswith(file_format):
                models.append(osp.join(dirpath, name))


def check_model_sbo(filename):
    model = read_sbml_model(filename)
    metabolite_sbo = 0
    for met in model.metabolites:
        if "sbo" in met.annotation:
            metabolite_sbo += 1
    try:
        metabolite_sbo /= len(model.metabolites)
    except ZeroDivisionError:
        metabolite_sbo = 0.0
    reaction_sbo = 0
    for rxn in model.reactions:
        if "sbo" in rxn.annotation:
            reaction_sbo += 1
    try:
        reaction_sbo /= len(model.reactions)
    except ZeroDivisionError:
        reaction_sbo = 0.0
    gene_sbo = 0
    for gene in model.genes:
        if "sbo" in gene.annotation:
            gene_sbo += 1
    try:
        gene_sbo /= len(model.genes)
    except ZeroDivisionError:
        gene_sbo = 0.0
    return (
        osp.basename(filename).split(".", 1)[0],
        metabolite_sbo,
        reaction_sbo,
        gene_sbo
    )


@click.command()
@click.help_option("--help", "-h")
@click_log.simple_verbosity_option(
    logger,
    default="INFO",
    show_default=True,
    type=click.Choice(["CRITICAL", "ERROR", "WARN", "INFO", "DEBUG"])
)
@click.option(
    "--file-format",
    default=".xml.gz",
    show_default=True,
    type=click.Choice([".xml.gz", ".xml", ".json.gz", ".json"]),
    help="Choose the desired file format to look for."
)
@click.option(
    "--filename",
    default="sbo.tsv",
    show_default=True,
    type=click.Path(exists=False, file_okay=True, dir_okay=False,
                    writable=True),
    help="Where to write the table of SBO statistics."
)
@click.argument(
    "paths",
    metavar="<MODEL PATH> [...]",
    nargs=-1,
    type=click.Path(exists=True, file_okay=False),
)
def main(paths, filename, file_format):
    files = []
    for base in paths:
        find_models(base, files, file_format)
    with multiprocessing.Pool(processes=3) as pool:
        result_iter = pool.imap_unordered(
            check_model_sbo, files, chunksize=len(files) // 3
        )
        rows = []
        for quad in tqdm(result_iter, total=len(files), desc="Models"):
            rows.append(quad)
    df = DataFrame(
        rows, columns=["model", "metabolite_sbo", "reaction_sbo", "gene_sbo"]
    )
    df.to_csv(filename, sep="\t", index=False, header=True)


if __name__ == "__main__":
    main()
