#!/bin/sh
# General options
# -- JobName --
#PBS -N memote-meta
# -- stdout/stderr redirection --
#PBS -o logs/$PBS_JOBNAME.$PBS_JOBID.out
#PBS -e logs/$PBS_JOBNAME.$PBS_JOBID.err
# -- specify queue --
#PBS -q hpc
# -- user email address --
# please uncomment the following line and put in your e-mail address,
# if you want to receive e-mail notifications on a non-default address
##PBS -M your_email_address
# -- mail notification --
#PBS -m abe
# -- Job array specification --
#PBS -t 1-20
# Number of cores
#PBS -l nodes=1:ppn=2
# specify the wall clock time (16 hours)
#PBS -l walltime=72:00:00
# Execute the job from the current working directory
cd $PBS_O_WORKDIR
source ~/miniconda3/bin/activate meta
python3.6 /work3/morbeb/Projects/run.py $PBS_ARRAYID
