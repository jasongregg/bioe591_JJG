#!/bin/bash
##
## This is a sbash script to sort aligned reads for task 5 
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are comments.
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics        #specify the account to use
#SBATCH --job-name=sort_d_glauca                        # job name
#SBATCH --partition=priority              # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at one except for MPI
#SBATCH --cpus-per-task=1              # number of cores to allocate
#SBATCH --time=0-00:30:00                 # Maximum job run time
#SBATCH --output=errors-outputs/jg_sort_d_glauca-%j.out
#SBATCH --error=errors-outputs/jg_sort_d_glauca-%j.err

# load module and activate mamba
module load Mamba/23.11.0-0

conda activate align

#this is the stock code from the lab
#samtools view -b sample.sam | samtools sort -o sample.sorted.bam
#samtools index sample.sorted.bam


###Here is a chatGPT generated loop based on stock code

for sam in /home/g24p229/bioe-591-genomics/students/jason-gregg/outputs/aligned/*.sam
do
    base=$(basename "$sam" .sam)
    samtools view -b "$sam" | samtools sort -o "/home/g24p229/bioe-591-genomics/students/jason-gregg/outputs/aligned/${base}.sorted.bam"
    samtools index "/home/g24p229/bioe-591-genomics/students/jason-gregg/outputs/aligned/${base}.sorted.bam"
    echo "Processed $base"
done
