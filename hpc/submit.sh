#!/bin/sh

# General options
# -- JobName --
#PBS -N memote-meta
# -- stdout/stderr redirection --
#PBS -o logs/$PBS_JOBNAME.$PBS_JOBID.out
#PBS -e logs/$PBS_JOBNAME.$PBS_JOBID.err
# -- specify queue --
#PBS -q hpc
# -- mail notification --
#PBS -m a
# -- Job array specification --
#PBS -t 1-20%120
# Number of nodes and cores per node.
#PBS -l nodes=1:ppn=2
# Specify the wall clock time per job in the array.
#PBS -l walltime=00:30:00

# Execute the job from the current working directory
cd $PBS_O_WORKDIR

# Activate the conda environment.
source ~/miniconda3/bin/activate meta

# Start a job with the desired number of processes (corresponds to `ppn`).
python3.6 /work3/morbeb/Projects/run.py --processes=1 models.tsv $PBS_ARRAYID
