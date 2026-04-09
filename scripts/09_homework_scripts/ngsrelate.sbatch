#!/bin/bash
##
## This is a sbash script to run ngsRelate on a sample dataset from Hauser et al 2022  for hw9 
##
## Lines starting with #SBATCH are read by Slurm. Lines starting with ## are comments.
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics        
#SBATCH --job-name=ngsrelate                            
#SBATCH --partition=priority              
#SBATCH --nodes=1                       
#SBATCH --ntasks-per-node=1             
#SBATCH --cpus-per-task=1              
#SBATCH --time=0-10:00:00                 
#SBATCH --output=ngsrelate-%j.out
#SBATCH --error=ngsrelate-%j.err

module load Mamba/23.11.0-0;
eval "$(conda shell.bash hook)"

conda activate ngsrelate

# gzip the vcf
bcftools view -Oz -o ../data/kinship/Inca_MaxMissing10.recode.vcf.gz ../data/kinship/Inca_MaxMissing10.recode.vcf

# index the vcf
tabix -p vcf ../data/kinship/Inca_MaxMissing10.recode.vcf.gz

# generate a sample ID file 
bcftools query -l ../data/kinship/Inca_MaxMissing10.recode.vcf.gz > ../data/kinship/Inca_MaxMissing10.recode_ids.txt

# call ngsRelate
ngsRelate -h ../data/kinship/Inca_MaxMissing10.recode.vcf.gz -T GT -c 1 -O ../data/kinship/Inca_MaxMissing10.recode.ngsrelate.out -z ../data/kinship/Inca_MaxMissing10.recode_ids.txt
