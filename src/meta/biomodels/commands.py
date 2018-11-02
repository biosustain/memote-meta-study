# -*- coding: utf-8 -*-

# Copyright 2018 Novo Nordisk Foundation Center for Biosustainability,
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

"""Download and test models from the BioModels database."""

import logging
from os.path import join
from multiprocessing import cpu_count

import click

from meta.testing import test_models
from meta.biomodels.download import download_bio_models

LOGGER = logging.getLogger()


@click.group()
@click.help_option("--help", "-h")
def biomodels():
    """Commands for the BioModels meta study."""
    pass


@biomodels.command()
@click.help_option("--help", "-h")
@click.option("--directory", type=click.Path(exists=True, file_okay=False,
                                             writable=True),
              default=join(".", "models", "biomodels"), show_default=True,
              help="Where to store the downloaded models.")
@click.option("--format", type=click.Choice([".xml"]),
              default=".xml", show_default=True,
              help="Choose the desired model format.")
def download(directory, format):
    """Download all models from the BioModels database and store them."""
    download_bio_models(directory, file_format=format)


@biomodels.command()
@click.help_option("--help", "-h")
@click.option("--models", type=click.Path(exists=True, file_okay=False,
                                          writable=True),
              default=join(".", "models", "biomodels"), show_default=True,
              help="Where to find the models.")
@click.option("--directory", type=click.Path(exists=True, file_okay=False,
                                             writable=True),
              default=join(".", "data", "biomodels"), show_default=True,
              help="Where to store the results.")
@click.option("--format", type=click.Choice([".xml"]),
              default=".xml", show_default=True,
              help="Choose the desired SBML model format.")
@click.option("--processes", "-p", type=int, default=cpu_count(),
              show_default=True, help="Select the number of processes to use.")
def test(models, directory, format, processes):
    """Test all downloaded BioModels models."""
    test_models(models, directory, file_format=format, num_proc=processes)
