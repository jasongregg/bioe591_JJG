#!/bin/bash
##
##random.subsample.slurm.sh
##
##this script is written for use on tempest
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are comments.
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics        #specify the account to use
#SBATCH --job-name=jg_week4_subsample.job                             # job name
#SBATCH --partition=priority              # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at one except for MPI
#SBATCH --cpus-per-task=1              # number of cores to allocate
#SBATCH --time=0-00:10:00                 # Maximum job run time
#SBATCH --output=outputs/jg_seqtk_subsample-%j.out
#SBATCH --error=outputs/jg_seqtk_subsample-%j.err

## Run 'man sbatch' for more information on the options above.

module load Mamba/23.11.0-0
eval "$(conda shell.bash hook)"

#activate yml conda env
conda activate demo_new

#no longer need the below
##echo "reads	bases" > size.txt
###seqtk size ~/bioe-591-genomics/course-materials/data/intro/catamenia_analis.fastq.gz >> size.txt

# Define input and output
# Input file
INPUT=/home/g24p229/bioe-591-genomics/course-materials/data/intro/catamenia_analis.fastq.gz

# Output file
OUTPUT=/home/g24p229/bioe-591-genomics/students/jason-gregg/outputs/catamenia_analis_1k_random_reads_${SLURM_JOB_ID}.fastq

# Randomly sample 1000 reads
seqtk sample -s100 $INPUT 1000 > $OUTPUT
