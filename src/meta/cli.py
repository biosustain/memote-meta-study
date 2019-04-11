#!/usr/bin/env python
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

""""""

import logging

import click
import click_log

from meta.etl import extract_transform_load

logger = logging.getLogger()
click_log.basic_config(logger)
logging.getLogger("memote").setLevel(logging.WARNING)


@click.group()
@click.help_option("--help", "-h")
@click_log.simple_verbosity_option(
    logger,
    default="INFO",
    show_default=True,
    type=click.Choice(["CRITICAL", "ERROR", "WARN", "INFO", "DEBUG"])
)
def cli():
    """Command line tools for a memote meta study."""
    pass


@cli.command()
@click.help_option("--help", "-h")
@click.argument(
    "data",
    type=click.Path(exists=True, file_okay=False)
)
@click.argument(
    "output",
    type=click.Path(exists=False, file_okay=True, writable=True)
)
@click.option(
    "--file-format",
    default=".json.gz",
    show_default=True,
    type=click.Choice([".json.gz", ".json"]),
    help="Choose the desired file format to look for."
)
def etl(data, output, file_format):
    """Extract all results and transform them to a tabular format."""
    extract_transform_load(data, output, file_format)
