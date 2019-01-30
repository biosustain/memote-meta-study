import logging
import os
import sys

import click
import click_log
import cobra
import memote
import pandas as pd
from memote.utils import stdout_notifications


logger = logging.getLogger()
click_log.basic_config(logger)
cobra_config = cobra.Configuration()


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
    "--processes",
    default=MAX_PROCESSES,
    show_default=True,
    type=click.IntRange(1, MAX_PROCESSES),
    metavar="NUM",
    help="The number of processes that memote should use for parallel tasks."
)
@click.option(
    "--solver",
    default="glpk",
    show_default=True,
    type=click.Choice(["cplex", "glpk", "gurobi", "glpk_exact"]),
    help="Set the mathematical optimization solver to be used."
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
def main(jobs_table, index, processes, solver):
    """
    Run memote on a given model and output combination.

    The model and output are read from the given TSV file <JOBS TABLE> and the
    specific row index <JOB ROW INDEX>. The index should be between 1 and the
    total number of rows.

    """
    cobra_config.solver = solver
    cobra_config.processes = processes
    df = pd.read_table(jobs_table, sep="\t", header=0)[["model", "output"]]
    # Transform PBS_ARRAYID to table location.
    model_file = df.iat[index - 1, 0]
    output = df.iat[index - 1, 1]
    model, sbml_ver, notifications = memote.validate_model(model_file)
    if model is None:
        logger.critical(
            "The model could not be loaded due to the following SBML errors.")
        stdout_notifications(notifications)
        sys.exit(1)
    manager = memote.ResultManager()
    code, result = memote.test_model(
        model=model,
        sbml_version=sbml_ver,
        results=True,
        pytest_args=["-vv", "--tb", "long"]
    )
    manager.store(result, filename=output, pretty=True)


if __name__ == "__main__":
    main()
