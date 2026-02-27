#!/bin/bash
##
## This is a sbash script to create mapping stats for my sorted, aligned reads. It produces text files titled alignment_stats.txt that I need
## which gives me alignment summary statistics such as percentage of reads mapped. 
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are comments.
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics        #specify the account to use
#SBATCH --job-name=align_mapping_stats_d_glauca                        # job name
#SBATCH --partition=priority              # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at one except for MPI
#SBATCH --cpus-per-task=1              # number of cores to allocate
#SBATCH --time=0-00:30:00                 # Maximum job run time
#SBATCH --output=errors-outputs/align_mapping_stats_d_glauca-%j.out
#SBATCH --error=errors-outputs/align_mapping_stats_d_glauca-%j.err

# load module and activate mamba
module load Mamba/23.11.0-0
eval "$(conda shell.bash hook)"

# activate your align environment which contains your bwa and samtools
conda activate align

#This is the base code offered by Ethan in the lab
#samtools flagstat sample.sorted.bam > alignment_stats.txt
#samtools depth sample.sorted.bam | awk '{sum+=$3} END {print sum/NR}' > depth.txt


##chat gpt loop with fixed path
for bam in $HOME/bioe-591-genomics/students/jason-gregg/outputs/aligned/*.sorted.bam
do
    base=$(basename "$bam" .sorted.bam)

    samtools flagstat "$bam" > $HOME/bioe-591-genomics/students/jason-gregg/outputs/aligned/mapping_stats/${base}_alignment_stats.txt

    samtools depth "$bam" | \
    awk '{sum+=$3} END {print sum/NR}' > $HOME/bioe-591-genomics/students/jason-gregg/outputs/aligned/mapping_stats/${base}_depth.txt

done

