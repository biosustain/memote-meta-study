import logging
import os
import subprocess
import sys

import click
import click_log
import pandas as pd


logger = logging.getLogger()
click_log.basic_config(logger)


try:
    MAX_PROCESSES = len(os.sched_getaffinity(0))
except OSError:
    logger.warning(
        "Could not determine the number of available cores - assuming 1."
    )
    MAX_PROCESSES = 1


@click.command()
@click.help_option("--help", "-h")
@click_log.simple_verbosity_option(
    logger,
    default="INFO",
    show_default=True,
    type=click.Choice(["CRITICAL", "ERROR", "WARN", "INFO", "DEBUG"])
)
@click.option(
    "--processes", "-p",
    default=MAX_PROCESSES,
    show_default=True,
    type=click.IntRange(1, MAX_PROCESSES),
    help="The number of processes that memote should use for parallel tasks."
)
@click.argument(
    "jobs_table",
    metavar="<JOBS TABLE>",
    type=click.Path(exists=True, file_okay=True, dir_okay=False),
)
@click.argument(
    "index",
    metavar="<JOB ROW INDEX>",
    type=click.INT,
)
def main(jobs_table, index, processes):
    """
    Run memote on a given model and output combination.

    The model and output are read from the given TSV file <JOBS TABLE> and the
    specific row index <JOB ROW INDEX>. The index should be between 1 and the
    total number of rows.

    """
    df = pd.read_table(jobs_table, sep="\t", header=0)[["model", "output"]]
    # Transform PBS_ARRAYID to table location.
    model = df.iat[index - 1, 0]
    output = df.iat[index - 1, 1]
    subprocess.call(
        ["memote", "run", "--processes", processes, "--filename", output, model]
    )


if __name__ == "__main__":
    main()
