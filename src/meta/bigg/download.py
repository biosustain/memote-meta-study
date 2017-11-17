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

"""Download content from the BiGG database."""

import logging
import io
import threading
from os.path import exists, join
from queue import Queue
from time import sleep, time

import requests
from requests.compat import urljoin
from tqdm import trange

__all__ = ("BiGGDownloader", "download_bigg_models")

LOGGER = logging.getLogger(__name__)
TIMEOUT = 10


class BiGGDownloader(threading.Thread):
    """
    GET results from BiGG concurrently.

    Since this task is IO bounded and not CPU bounded, Python
    ``threading.Threads`` are fair game.

    """

    def __init__(self, task_queue, result_queue, wait, guard=None, **kwargs):
        """
        Iterate a queue with URLs and download the elements.

        Parameters
        ----------
        task_queue : queue.Queue
            The input queue to watch.
        wait : float
            BiGG has a limit of 10 requests per second. Make the threads wait.
            This will be a conservative upper bound since the download itself
            takes time as well.
        guard : object
            Any Python instance to expect to signal the end of the task queue.
        kwargs
            Keyword arguments are passed on to the threading.Thread constructor.

        """
        super(BiGGDownloader, self).__init__(**kwargs)
        self.task_queue = task_queue
        self.result_queue = result_queue
        self.wait = wait
        self.guard = guard

    def run(self):
        """Issue GET requests until the guard value is found in the queue."""
        for job in iter(self.task_queue.get, self.guard):
            start = time()
            url, output = job
            if exists(output):
                LOGGER.warning("%s: '%s' already exists. Skipping.", self.name,
                               output)
                self.result_queue.put((output, None))
                continue
            response = requests.get(url, timeout=TIMEOUT)
            LOGGER.debug("%s: %d - %s", self.name, response.status_code,
                         response.reason)
            response.raise_for_status()
            self.result_queue.put((output, response.content))
            # Reduce the waiting time by the processing time.
            wait = self.wait - time() + start
            if wait > 0.0:
                sleep(self.wait)


def download_bigg_models(output_dir, file_format=".xml.gz", num_threads=3,
                         guard=None):
    """
    Download all models from BiGG and store them.

    Parameters
    ----------
    output_dir : str or pathlib.Path
        The directory where to store the downloads.
    base_url : str, optional
        Where to check for existing models and load them.
    file_format : {'.xml.gz', '.xml', '.json', '.mat'}, optional
        What format should the model files have?
    num_threads : int, optional
        The number of threads to use for downloads.
    guard : object
        Any Python instance to serve as a queue guard, i.e., when encountered in
        the queue by the threads they will terminate.

    """
    models_response = requests.get("http://bigg.ucsd.edu/api/v2/models/",
                                   timeout=TIMEOUT)
    LOGGER.debug("%d - %s", models_response.status_code, models_response.reason)
    models_response.raise_for_status()
    content = models_response.json()
    num_models = content["results_count"]
    LOGGER.info("%d potential models to download.", num_models)
    LOGGER.debug("Starting %d threads.", num_threads)
    task_q = Queue()
    result_q = Queue()
    threads = [BiGGDownloader(
        task_q, result_q, wait=num_threads / 10, guard=guard)
        for _ in range(num_threads)]
    for t in threads:
        t.start()
    LOGGER.debug("Submitting downloads...")
    for model in content["results"]:
        model_id = model["bigg_id"]
        model_file = model_id + file_format
        task_q.put((urljoin("http://bigg.ucsd.edu/static/models/", model_file),
                   join(output_dir, model_file)))
    # Submit guard to safely end threads.
    for _ in range(num_threads):
        task_q.put(guard)
    LOGGER.debug("Saving downloads...")
    for _ in trange(num_models):
        output, res = result_q.get()
        if res is None:
            continue
        with io.open(output, "wb", encoding=None) as file_h:
            file_h.write(res)
    for t in threads:
        t.join()
    LOGGER.debug("Done.")

