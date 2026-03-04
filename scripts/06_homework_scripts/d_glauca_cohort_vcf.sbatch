#!/bin/bash
##
##this is an mpileup test script from lab 6 to produce a vcf file
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are comments.
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics        #specify the account to use
#SBATCH --job-name=d_glauca_cohort_vcf                        # job name
#SBATCH --partition=priority              # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at one except for MPI
#SBATCH --cpus-per-task=1              # number of cores to allocate
#SBATCH --time=0-00:30:00                 # Maximum job run time
#SBATCH --output=errors-outputs/d_glauca_vcf_test-%j.out
#SBATCH --error=errors-outputs/d_glauca_vcf_test-%j.err

# load module and activate mamba
module load Mamba/23.11.0-0
eval "$(conda shell.bash hook)"

# activate your fastp environment
conda activate bcftools

bcftools mpileup -f $HOME/bioe-591-genomics/students/jason-gregg/data/hemoglobin_references.fasta $HOME/bioe-591-genomics/students/jason-gregg/outputs/aligned/*sorted.bam | bcftools call -mv -Ov -o d_glauca_multisample.vcf




