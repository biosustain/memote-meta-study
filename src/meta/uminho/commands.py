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

"""Download and test models from the UMinho database."""

from __future__ import absolute_import

import logging
from os.path import join
from multiprocessing import cpu_count

import click

from meta.testing import test_models
from meta.uminho.download import download_uminho_models

LOGGER = logging.getLogger()


@click.group()
@click.help_option("--help", "-h")
def uminho():
    """Commands for the UMinho meta study."""
    pass


@uminho.command()
@click.help_option("--help", "-h")
@click.option("--directory", type=click.Path(exists=True, file_okay=False,
                                             writable=True),
              default=join(".", "models", "uminho"), show_default=True,
              help="Where to store the downloaded models.")
@click.option("--format", type=click.Choice([".xml"]),
              default=".xml", show_default=True,
              help="Choose the desired model format.")
def download(directory, format):
    """
    Download all models from the UMinho database and store them.

    (http://darwin.di.uminho.pt/models)
    """
    download_uminho_models(directory, file_format=format)


@uminho.command()
@click.help_option("--help", "-h")
@click.option("--models", type=click.Path(exists=True, file_okay=False,
                                          writable=True),
              default=join(".", "models", "uminho"), show_default=True,
              help="Where to find the models.")
@click.option("--directory", type=click.Path(exists=True, file_okay=False,
                                             writable=True),
              default=join(".", "data", "uminho"), show_default=True,
              help="Where to store the results.")
@click.option("--format", type=click.Choice([".xml"]),
              default=".xml", show_default=True,
              help="Choose the desired model format.")
@click.option("--processes", "-p", type=int, default=cpu_count(),
              show_default=True, help="Select the number of processes to use.")
def test(models, directory, format, processes):
    """Test all downloaded UMinho models."""
    test_models(models, directory, file_format=format, num_proc=processes)
