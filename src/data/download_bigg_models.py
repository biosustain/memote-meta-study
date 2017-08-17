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

"""Download all models from the BiGG database."""

from __future__ import absolute_import

import logging
import sys
from os.path import dirname, join

SRC_DIR = join(dirname(__file__), "..")

sys.path.insert(0, SRC_DIR)

from bigg import download_bigg_models

LOGGER = logging.getLogger()


if __name__ == "__main__":
    logging.basicConfig(level="INFO", format="%(levelname)s - %(message)s")
    download_bigg_models(join(SRC_DIR, "../models/"))

