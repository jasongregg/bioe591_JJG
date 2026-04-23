Jason Gregg
Bioe591
April 23, 2026

HW10 README

Data are from Mikles et al. and form the basis of Walsh et al. 2020.

Data were downloaded from Dryad: https://datadryad.org/dataset/doi:10.5061/dryad.ncjsxkssb#methods

Walsh et al. 2020 "We used reduced-representation sequencing to generate 2,773 SNPs to explore 
genetic differentiation, spatial population structure, and demographic history. Clustering 
separated individuals from each of the six subspecies, indicating subtle differentiation 
at microgeographic scales. Evidence of limited gene flow and low nucleotide diversity 
across all six subspecies further supports a hypothesis of isolation among locally 
adapted populations."


**Results**

R and sbatch scripts are saved under Scripts.

Based on both analysis, K=2 had the most support in both ADMIXTUERE and DAPC. This is consistent
with the original study, which used structure and found that.. "For all subspecies, K = 2 
is most optimal, separating pusillula from the rest of the subspecies..." Like Walsh et al.
2020, I also found support for K=6, corresponding to the 6 differentiated Song sparrow populations 
they find evidence for in the study.

Support for K=6 and the sub-structure K=2 can be seen visually in my ADMIXTURE and DAPC 
output figures: K_series_ADMIXTURE.png and K_series_DAPC.png. 

K=2 was also supported by admixture cross validation values and DAPC bic (see output). 


