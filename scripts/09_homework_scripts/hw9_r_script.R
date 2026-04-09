#Jason Gregg
#BIOE591 HW9
#April 8, 2026


#setwd
setwd('bioe-591-genomics/students/jason-gregg')

#install packages
install.packages("related", repos="http://R-Forge.R-project.org")
install.packages("adegenet")
install.packages("vcfR")
install.packages("pegas")
install.packages("gridExtra")
install.packages("grid")

#load packages
library(related)
library(adegenet)
library(vcfR)
library(pegas)
library(tidyverse)
library(reshape2)
library(ggplot2)
library(tidyr)
library(dplyr)
library(gridExtra)
library(grid)

#load your vcf data
vcf <- read.vcfR(file = "data/kinship/Inca_MaxMissing10.recode.vcf", verbose = TRUE)

#convert into a genind object
genind_obj <- vcfR2genind(vcf)

#check out the data
genind_obj
head(genind_obj@tab)
summary(genind_obj@loc.n.all)

#We can next calculate observed and expected heterozygosity at each locus (SNP) 
#using adegenet’s summary() function and then selecting the appropriate attributes 
#from its output with the $ operator. 
af_summary <- adegenet::summary(genind_obj) # here it is important to specify which package's summary function is used!
af_summary # view object
h_o <- af_summary$Hobs
h_e <- af_summary$Hexp

#this will let you see, across all loci, He Observerd and He expected

#Check out these summaries
head(h_o)
head(h_e)
het_df <- data.frame(locus = names(h_o), h_o = h_o, h_e = h_e)
head(het_df)

#now lets calculate FIS, the inbreeding coefficient, which is
# 1- Ho/He
Fis_per_locus <- 1 - (h_o / H_e)
Fis_per_locus
mean(Fis_per_locus, na.rm = TRUE)

#now lets use pegas to assess whether loci are in HWE 
#the argument B = 100 specifies the number of replicates for a Monte Carlo allele 
#permutation procedure; this necessarily takes some time (1-5 minutes), 
#which will scale with the value you select.
loci_obj <- genind2loci(genind_obj)
hwe_results <- pegas::hw.test(loci_obj, B = 100)
hwe_results

#isolate significant deviations from HWE by filtering the p-value column (Pr.exact) 
#by a threshold of your choosing:
hwe_results %>% as.tibble() %>% filter(Pr.exact<0.05)

#related relies on its own custom data format, which we will have to convert manually 
#from the genotype matrix of our initial vcfR object using the extract.gt() function:
gt_filtered <- vcfR::extract.gt(vcf, element = "GT")

#We can then perform a tedious set of operations to cover these data—presented 
#as character strings—into a dataframe of integers:
# sample ids
sample_ids <- colnames(gt_filtered)

gt_to_alleles <- function(gt_vector) {
  # split "0/1" or "0|1" into two integer alleles, returning a 2-column matrix (samples x 2 alleles)
  allele1 <- integer(length(gt_vector))
  allele2 <- integer(length(gt_vector))
  
  for (i in seq_along(gt_vector)) {
    g <- gt_vector[i]
    if (is.na(g) || g %in% c("./.", ".", "./", "/.")) {
      allele1[i] <- 0
      allele2[i] <- 0
    } else {
      parts <- as.integer(strsplit(g, "[/|]")[[1]])
      allele1[i] <- parts[1] + 1L    # shift: 0->1 (ref), 1->2 (alt)
      allele2[i] <- parts[2] + 1L
    }
  }
  cbind(allele1, allele2)
}

allele_list <- vector("list", nrow(gt_filtered))

for (v in seq_len(nrow(gt_filtered))) {
  allele_list[[v]] <- gt_to_alleles(gt_filtered[v, ])
}

# combine: each element is (n_samples x 2); bind column-wise
allele_matrix <- do.call(cbind, allele_list)

# add individual IDs as the first column
coancestry_input <- data.frame(IndID = sample_ids, allele_matrix,
                               stringsAsFactors = FALSE)

# column names: IndID, L1_a, L1_b, L2_a, L2_b, ...
locus_names <- paste0(rep(paste0("L", seq_len(nrow(gt_filtered))),
                          each = 2),
                      rep(c("_a", "_b"), nrow(gt_filtered)))

colnames(coancestry_input) <- c("IndID", locus_names)


######### This will be large in both dimenions, so previewing its structure 
#is best done by slicing column and row indices down to something manageable:

coancestry_input[1:5, 1:7]

kin_results <- related::coancestry(
  genotype.data = coancestry_input,
  wang          = 1,      # 1 = compute; 0 = skip
  dyadml        = 1,
  quellergt     = 1
)

head(kin_results$relatedness)


#############
#############
##HW assignment 9
#############
#############

#create histograms of these relatedness values for all 3
#of the calculated metrics

ggplot(kin_results$relatedness, aes(x = wang)) +
  geom_histogram(binwidth = 0.02, fill = "skyblue", color = "black") +
  theme_minimal() +
  labs(title = "Wang Relatedness Distribution",
       x = "Relatedness",
       y = "Count")

###lets try faceting three plots, so I can see the three estimators side by side
#long format data
# Select and reshape the three estimators
rel_long <- kin_results$relatedness %>%
  select(wang, dyadml, quellergt) %>%
  pivot_longer(cols = everything(),
               names_to = "estimator",
               values_to = "relatedness") %>%
  filter(!is.na(relatedness))

#plot
# Plot small multiples
ggplot(rel_long, aes(x = relatedness, fill = estimator)) +
  geom_histogram(binwidth = 0.02, color = "black") +
  facet_wrap(~ estimator, scales = "free_y") +
  scale_fill_manual(values = c(
    "wang" = "#1f78b4",
    "dyadml" = "#33a02c",
    "quellergt" = "#e31a1c"
  )) +
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(hjust = 0.5)  # centers title
  ) +
  labs(
    title = "Inca Tern Relatedness Distributions by Estimator",
    x = "Relatedness",
    y = "Count"
  )

###Now load your output you generated on the cluser with ngsRelate, so that you can
###compare these two approaches.

#load the ngs output file
ngs <- read.delim("data/kinship/Inca_MaxMissing10.recode.ngsrelate.out")

head(ngs)

#chatgpt recommends converting ngs theta to relatedness in order to scale the data
#equivilentatly to your other three relatedness values

ngs$theta_rel <- 2 * ngs$theta

#Now you need to include this data into your long format table:
theta_long <- data.frame(
  estimator = "theta_rel",
  relatedness = ngs$theta_rel
)

rel_long <- bind_rows(rel_long, theta_long)

#now try plotting:
ggplot(rel_long, aes(x = relatedness, fill = estimator)) +
  geom_histogram(binwidth = 0.02, color = "black") +
  facet_wrap(~ estimator, scales = "free_y", ncol = 2) +  # 2x2 layout
  scale_fill_manual(values = c(
    "wang" = "#1f78b4",       # blue
    "dyadml" = "#33a02c",     # green
    "quellergt" = "#e31a1c",  # red
    "theta_rel" = "#ff7f00"   # orange
  )) +
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_text(hjust = 0.5)  # center title
  ) +
  labs(
    title = "Inca Tern Relatedness Distributions by Estimator",
    x = "Relatedness",
    y = "Count"
  )

######
##### seemed to work

###now lets us dplyr to create a table of summary stats

summary_stats <- rel_long %>%
  group_by(estimator) %>%
  summarise(
    n = n(),
    mean = mean(relatedness),
    median = median(relatedness),
    sd = sd(relatedness),
    min = min(relatedness),
    max = max(relatedness),
    q1 = quantile(relatedness, 0.25),
    q3 = quantile(relatedness, 0.75),
    iqr = IQR(relatedness)
  )

summary_stats

# Create a table grob
table_grob <- tableGrob(summary_stats)

# Save as PNG
png("relatedness_summary.png", width = 1200, height = 800)
grid.draw(table_grob)
dev.off()


