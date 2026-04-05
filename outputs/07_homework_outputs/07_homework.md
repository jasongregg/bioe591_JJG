Jason Gregg
bioe591 - Ethan Linck
HW7
April 5, 2026


I used the following filters in script: hw7_vcftools_filter.sbatch
The input was a multi sample vcf file based on all my D glauca samples.


--remove-indels 

This removes insertions and deletions, leaving only SNPs in the data.


--minQ 40 

This filter removes sites with a Phred score lower than 40. A Phred score is a measure 
of confidence of a variant call. Higher read depth allows for more confidence of a variant.

--mac 2  

This filters out alleles if they occur less two or fewer times in the data. This could be
rare alleles or error.


--max-missing-count 1  

This filters out any sites that are missing in one or more of the individuals in the dataset


--min-meanDP 10 

This filters out any sites that have a mean depth value equal to or less than 10. According to chatgpt, 
variation in read depth is caused during sequencing as well as variable sample quality and 
reasons related to genome and dna structure.

--thin 50 

This filters any sites that are closer than 50 nucleotides apart. This seems to be a quick and
dirty way of dealing with linkage disequilibrium by filtering based on physical proximity,
as a quick way to look at the data.

This ended up filtering pretty aggressively. I looked at my .err file and it kept 6/6 ind. 
and 51 out of a possible 399 Sites - my guess is the thin 50 doesn't work that well with such a small
number of bp


After running the above filtering script, I also ran the following summary statistic script:

hw7_vcftools_summary.sbatch

I summarized the data using --hardy, producing a hwe file in my outputs folder.





