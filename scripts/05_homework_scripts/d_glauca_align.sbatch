#!/bin/bash
##
## This is a sbash script to align my filtered D glauca reads to a reference sequence using bwa and samtools for Assignment 5 
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are comments.
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics        #specify the account to use
#SBATCH --job-name=align_D_glauca                        # job name
#SBATCH --partition=priority              # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at one except for MPI
#SBATCH --cpus-per-task=1              # number of cores to allocate
#SBATCH --time=0-01:30:00                 # Maximum job run time
#SBATCH --output=errors-outputs/jg_align_d_glauca-%j.out
#SBATCH --error=errors-outputs/jg_align_d_glauca-%j.err

# load module and activate mamba
module load Mamba/23.11.0-0
eval "$(conda shell.bash hook)"

# activate your align environment which contains your bwa and samtools
conda activate align

#First we need to index the reference sequence using both tools
#this was done with a seperate sbatch script previously. The output files are in the same location as hemoglobin_references.fasta

#now try running a loop to running these align tools on all your sample trimmed read R1/R2 pairs

##chat gpt loop
for R1 in /home/g24p229/bioe-591-genomics/students/jason-gregg/outputs/trimmed_reads/*_R1_trimmed.fastq.gz
do
    base=$(basename "$R1" _R1_trimmed.fastq.gz)
    R2="/home/g24p229/bioe-591-genomics/students/jason-gregg/outputs/trimmed_reads/${base}_R2_trimmed.fastq.gz"
    
    bwa mem -t 4 \
    /home/g24p229/bioe-591-genomics/students/jason-gregg/data/hemoglobin_references.fasta \
    "$R1" "$R2" > "/home/g24p229/bioe-591-genomics/students/jason-gregg/outputs/aligned/${base}.sam"
done


