#!/bin/bash
##
## example-array.slurm.sh: submit an array of jobs with a varying parameter
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are comments.
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics        #specify the account to use
#SBATCH --job-name=fastp_D_glauca                        # job name
#SBATCH --partition=priority              # queue partition to run the job in
#SBATCH --nodes=1                       # number of nodes to allocate
#SBATCH --ntasks-per-node=1             # number of descrete tasks - keep at one except for MPI
#SBATCH --cpus-per-task=1              # number of cores to allocate
#SBATCH --time=0-00:30:00                 # Maximum job run time
#SBATCH --output=jg_fastp_D_glauca-%j.out
#SBATCH --error=jg_fastp_D_glauca-%j.err

# load module and activate mamba
module load Mamba/23.11.0-0
eval "$(conda shell.bash hook)"

# activate your fastp environment
conda activate fastp

## this is the loop, adapted from Ethan's lab excercise page. for starts the loop, *expands to all files in that folder, R2 matches the 
##file pair, and line 3 extracts the sample name
for r1 in ~/bioe-591-genomics/course-materials/data/raw_reads/Diglossa_glauca/*_R1*.fastq.gz; do
  r2="${r1/_R1/_R2}"
  sample=$(basename "$r1" | sed 's/_R1.*//')

echo "Processing $sample..."

##these are the actual fastp commands
  fastp \
    -i "$r1" \
    -I "$r2" \
    -o "$HOME/bioe-591-genomics/students/jason-gregg/outputs/trimmed_reads/${sample}_R1_trimmed.fastq.gz" \
    -O "$HOME/bioe-591-genomics/students/jason-gregg/outputs/trimmed_reads/${sample}_R2_trimmed.fastq.gz" \
    -h "$HOME/bioe-591-genomics/students/jason-gregg/outputs/trimmed_reads/${sample}.fastp.html" \
    -j "$HOME/bioe-591-genomics/students/jason-gregg/outputs/trimmed_reads/${sample}.fastp.json"

done


