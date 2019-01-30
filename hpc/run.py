import logging
import subprocess
import sys

import click_log
import pandas as pd


logger = logging.getLogger()
click_log.basic_config(logger)


def main(filename, index):
    df = pd.read_table(filename, sep="\t", header=0)[["model", "output"]]
    # Transform PBS_ARRAYID to table location.
    model = df.iat[index - 1, 0]
    output = df.iat[index - 1, 1]
    subprocess.call(["memote", "run", "--filename", output, model])


if __name__ == "__main__":
    if len(sys.argv) != 3:
        logger.critical("Usage: %s <table> <row index>", __file__)
        sys.exit(2)
    main(sys.argv[1], int(sys.argv[2]))
