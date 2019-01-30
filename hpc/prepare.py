import logging
import os
import os.path as osp

import click
import click_log
import pandas as pd


logger = logging.getLogger()
click_log.basic_config(logger)


def find_models(base, model_prefix, data_prefix, models, results, file_format):
    for dirpath, dirnames, filenames in os.walk(base):
        logger.debug(dirpath)
        out_path = osp.normpath(osp.join(
            data_prefix, osp.relpath(dirpath, model_prefix)
        ))
        logger.debug(out_path)
        # Continue walking the directories if there are no model files in the
        # current directory.
        if any(f.endswith(file_format) for f in filenames):
            os.makedirs(out_path, exist_ok=True)
        else:
            continue
        for name in filenames:
            result = osp.normpath(osp.join(
                out_path, f"{name[:-len(file_format)]}.json.gz"
            ))
            if osp.isfile(result):
                continue
            models.append(osp.join(dirpath, name))
            results.append(result)


@click.command()
@click.help_option("--help", "-h")
@click_log.simple_verbosity_option(
    logger,
    default="INFO",
    show_default=True,
    type=click.Choice(["CRITICAL", "ERROR", "WARN", "INFO", "DEBUG"])
)
@click.option(
    "--model-prefix",
    default="models",
    show_default=True,
    type=click.Path(exists=True, file_okay=False),
    help="The common models path prefix."
)
@click.option(
    "--data-prefix",
    default="data",
    show_default=True,
    type=click.Path(exists=True, file_okay=False),
    help="The common data path prefix."
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
    default="models.tsv",
    show_default=True,
    type=click.Path(exists=False, file_okay=True),
    help="Where to write the table of collected models."
)
@click.argument(
    "paths",
    metavar="<MODEL PATH> [...]",
    nargs=-1,
    type=click.Path(exists=True, file_okay=False),
)
def main(paths, model_prefix, data_prefix, file_format, filename):
    """
    Find model files to be evaluated and write them to a table.

    Model sub-directories are maintained using a prefix, for example, if the
    model-prefix is 'models' and the data-prefix is 'data' then a model found
    at:

        models/sub/collection/organism.xml.gz

    has its result written to:

        data/sub/collection/organism.json.gz

    """
    models = []
    results = []
    for base in paths:
        find_models(
            base,
            model_prefix, data_prefix, models, results, file_format)
    df = pd.DataFrame({
        "model": models,
        "output": results
    })
    logger.info("Found %d untested model files.", len(df))
    minutes = len(df) * 30
    logger.info("This corresponds to %02d:%02d:00 linear time.",
                minutes // 60, minutes % 60)
    df.to_csv(filename, sep="\t", index=False)


if __name__ == "__main__":
    main()
