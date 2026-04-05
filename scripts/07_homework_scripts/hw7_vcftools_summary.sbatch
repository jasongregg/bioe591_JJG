#!/bin/bash
##
##this is an vcftools test script from lab 7 to use vcftools to summarize a vcf$
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are co$
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics        #specify the account to use
#SBATCH --job-name=vcftools_summary_hw7                        # job name
#SBATCH --partition=priority              # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at on$
#SBATCH --cpus-per-task=1              # number of cores to allocate
#SBATCH --time=0-00:30:00                 # Maximum job run time
#SBATCH --output=errors-outputs/vcftools_hw7_summary-%j.out
#SBATCH --error=errors-outputs/vcftools_hw7_summary-%j.err

# load module and activate mamba
module load Mamba/23.11.0-0
eval "$(conda shell.bash hook)"

# activate your fastp environment
conda activate vcftools

vcftools --vcf final.recode.vcf --hardy --out hw7.summary


