#!/bin/bash
##
##script for lab 10 to run admixture with multiple values of k
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are co$
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics        #specify the account to use
#SBATCH --job-name=admix_multik                  # job name
#SBATCH --partition=priority              # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at on$
#SBATCH --cpus-per-task=1              # number of cores to allocate
#SBATCH --time=0-00:30:00                 # Maximum job run time
#SBATCH --output=errors-outputs/sosp_admix_multik-%j.out
#SBATCH --error=errors-outputs/sosp_admix_multik-%j.err

# load module and activate mamba

module load Mamba/23.11.0-0;
eval "$(conda shell.bash hook)"
conda activate admixture

for K in 2 3 4 5 6; do
  admixture --cv sosp.int.bed $K | tee sosp.log${K}.out
done
