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

"""Download content from the BioModels database."""

import asyncio
import logging
from os.path import exists, join

import requests
from lxml import html
from tqdm import tqdm
from zeep import Client
from zeep.asyncio import AsyncTransport


__all__ = ("download_bio_models",)


LOGGER = logging.getLogger(__name__)
URL = "https://www.ebi.ac.uk/biomodels-main/services/BioModelsWebServices?wsdl"


def scrape_model_ids():
    """Scrape the BioModels identifiers from the PATH2Models collection."""
    url = "https://www.ebi.ac.uk/biomodels-main/path2models?cat=genome-scale"
    response = requests.get(url)
    response.raise_for_status()
    dom = html.fromstring(response.content)
    return dom.xpath("//a[contains(@title,'Access to this model')]/@href")


async def load_model(client, output_dir, file_format, model_id):
    output = join(output_dir, model_id + file_format)
    if exists(output):
        return f"'{output}' already exists. Skipping.", True
    try:
        result = await client.service.getModelSBMLById(model_id)
    except Exception as err:
        return str(err), True
    if not result:
        return "No result returned.", True
    try:
        with open(output, "wb", encoding=None) as file_handle:
            file_handle.write(result)
    except IOError as err:
        return str(err), True
    return output, False


def download_bio_models(output_dir: str, file_format: str=".xml"):
    """Download all the models from the PATH2Models collection."""

    def result_callback(future: asyncio.Future):
        results = future.result()
        for output, res in results:
            if res:
                LOGGER.warning(output)
            pbar.update(1)

    # Get the BioModels identifiers for the PATH2Models collection.
    model_ids = scrape_model_ids()
    LOGGER.info("%d potential models to download.", len(model_ids))

    # Set up the asynchronous WSDL client.
    loop = asyncio.get_event_loop()
    transport = AsyncTransport(loop, cache=None)
    client = Client(URL, transport=transport)

    # Define the tasks and run them to completion.
    pbar = tqdm(total=len(model_ids))
    tasks = [load_model(client, output_dir, file_format, mid)
             for mid in model_ids]
    future = asyncio.gather(*tasks, loop=loop, return_exceptions=True)
    future.add_done_callback(result_callback)

    loop.run_until_complete(future)
    loop.run_until_complete(transport.session.close())
    loop.close()
    pbar.close()
