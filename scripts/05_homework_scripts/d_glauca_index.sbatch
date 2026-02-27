#!/bin/bash
##
## This is a sbash script to index my filtered D glauca reads to a reference sequence using bwa and samtools for Assignment 5 
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are comments.
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics        #specify the account to use
#SBATCH --job-name=index_d_glauca                        # job name
#SBATCH --partition=priority              # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at one except for MPI
#SBATCH --cpus-per-task=1              # number of cores to allocate
#SBATCH --time=0-00:30:00                 # Maximum job run time
#SBATCH --output=jg_index_d_glauca-%j.out
#SBATCH --error=jg_index_d_glauca-%j.err

# load module and activate mamba
module load Mamba/23.11.0-0
eval "$(conda shell.bash hook)"

# activate your align environment which contains your bwa and samtools
conda activate align

#First we need to index the reference sequence using both tools - the reference file was already copied into my student folder
bwa index /home/g24p229/bioe-591-genomics/students/jason-gregg/data/hemoglobin_references.fasta

samtools faidx /home/g24p229/bioe-591-genomics/students/jason-gregg/data/hemoglobin_references.fasta



