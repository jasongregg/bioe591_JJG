#!/bin/bash
##
##sbatch script for IQtree, lab 12 BIOE591
## All other lines are read by the shell.
##
#SBATCH --account=priority-bioe-591-genomics      
#SBATCH --job-name=iqtree                            
#SBATCH --partition=priority          
#SBATCH --nodes=1                      
#SBATCH --ntasks-per-node=1            
#SBATCH --cpus-per-task=1              
#SBATCH --time=0-01:00:00              
#SBATCH --output=errors-outputs/iqtree-%j.out
#SBATCH --error=errors-outputs/iqtree-%j.err

module load Mamba/23.11.0-0 # load mamba module
eval "$(conda shell.bash hook)" # make conda / mamba executable
conda activate iqtree # load iqtree environment 

bcftools view -v snps ../data/phylogenetics/lemurs.vcf.gz -Oz -o  ../data/phylogenetics/lemurs.snps.vcf.gz # filter vcf to SNPs
bcftools index ../data/phylogenetics/lemurs.snps.vcf.gz # index the vcf
python ../vcf2phylip/vcf2phylip.py -i ../data/phylogenetics/lemurs.snps.vcf.gz # convert the vcf to phylip
iqtree -s lemurs.snps.min4.phy -m GTR -bb 1000 -nt AUTO # run iqtree
