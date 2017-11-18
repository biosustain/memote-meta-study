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

"""Perform parallel metabolic model tests."""

import logging
import multiprocessing
from glob import glob
from os.path import join, basename, exists

import memote
from cobra.io import read_sbml_model
from tqdm import tqdm

__all__ = ("test_models",)

LOGGER = logging.getLogger(__name__)


def _worker(args):
    filename, output = args
    results = output + ".json"
    if exists(results):
        LOGGER.warning("The test results for '%s' already exist. Skipping.",
                       basename(output))
        return 2, filename
    try:
        model = read_sbml_model(filename)
    except Exception as err:
        LOGGER.error(str(err))
        return 2, filename
    code = memote.test_model(model, results, False, ["--tb", "no"])
    return code, filename


def test_models(model_dir, output_dir, file_format=".xml.gz",
                num_proc=multiprocessing.cpu_count()):
    """
    Test all metabolic models in the given directory with memote.

    Parameters
    ----------
    model_dir : str or pathlib.Path
        Where to find the metabolic models.
    output_dir : str or pathlib.Path
        The directory where to store the test results.
    file_format : {'.xml.gz', '.xml', '.json', '.mat'}, optional
        What format do the model files have?
    num_proc : int
        The number of processes to use for the parallel testing.

    """
    models = glob(join(model_dir, "*" + file_format))
    LOGGER.info("%d models to test.", len(models))
    pool = multiprocessing.Pool(processes=num_proc)
    tasks = list()
    for filename in models:
        out_name = basename(filename)[:-len(file_format)]
        output = join(output_dir, out_name)
        tasks.append((filename, output))
    LOGGER.debug("Submitting tasks...")
    result_iter = pool.imap_unordered(_worker, tasks)
    pool.close()
    with tqdm(total=len(models)) as pbar:
        for code, filename in result_iter:
            LOGGER.debug("The test exit code of '%s' is %d.", filename, code)
            pbar.update()
    pool.join()
    LOGGER.debug("Done.")

