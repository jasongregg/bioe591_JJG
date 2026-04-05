#!/bin/bash
##
##this is an vcftools test script from lab 7 to use vcftools to summarize a vcf file
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are comments.
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics        #specify the account to use
#SBATCH --job-name=d_glauca_vcftools_hw7                        # job name
#SBATCH --partition=priority              # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at one except for MPI
#SBATCH --cpus-per-task=1              # number of cores to allocate
#SBATCH --time=0-00:30:00                 # Maximum job run time
#SBATCH --output=errors-outputs/d_glauca_vcftools_hw7-%j.out
#SBATCH --error=errors-outputs/d_glauca_vcftools_hw7-%j.err

# load module and activate mamba
module load Mamba/23.11.0-0
eval "$(conda shell.bash hook)"

# activate your fastp environment
conda activate vcftools

vcftools --gzvcf d_glauca_multisample.vcf_rerun.gz --remove-indels --minQ 40 --mac 2  --max-missing-count 1  --min-meanDP 10 --minQ 40 --thin 50 --recode --out final
