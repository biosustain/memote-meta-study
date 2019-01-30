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

from meta.bigg.commands import bigg
# from meta.biomodels.commands import biomodels
from meta.mmodel.commands import mmodel
from meta.uminho.commands import uminho

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


cli.add_command(bigg)
# cli.add_command(biomodels)
cli.add_command(mmodel)
cli.add_command(uminho)
