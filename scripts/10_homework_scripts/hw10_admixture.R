#Jason Gregg
#bioe591, April 14, 2026
#hw10

#this is the r script associated with the r-based portion of hw10

setwd("bioe-591-genomics/students/jason-gregg/hw10_r/")

library(tidyverse)

# read sample names and extract
fam <- read_table("../scripts/sosp.int.fam", 
                  col_names = FALSE,
                  show_col_types = FALSE
)

head(fam)

samples <- fam$X2   # individual IDs are usually column 2

# choose your K value (will be 2 for this demo)
K <- 2

# read Q matrix
q <- read_table("../scripts/sosp.int.2.Q",
                col_names = FALSE,
                show_col_types = FALSE
)

# name the ancestry columns
colnames(q) <- paste0("Cluster", 1:K)

# combine with sample names
q_df <- q %>%
  mutate(sample = samples) %>%
  relocate(sample)

# convert to long format for ggplot
q_long <- q_df %>%
  pivot_longer(
    cols = starts_with("Cluster"),
    names_to = "cluster",
    values_to = "ancestry"
  ) %>%
  mutate(sample = factor(sample, levels = samples))

#######now try plotting with ggplot
# plot
ggplot(q_long, aes(x = sample, y = ancestry, fill = cluster)) +
  geom_col(width = 1, color="white") +
  theme_bw() +
  labs(x = "Individual", y = "Ancestry proportion") +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)
  )

#Lastly, we can make use of regex functions in R to extract our cross-validation 
#values from the log file:

cv_df <- tibble(file = "../scripts/errors-outputs/hw10_admix-3852672.out") %>%
  mutate(
    text = map_chr(file, read_file),
    cv_line = str_extract(text, "CV error \\(K=\\d+\\):\\s*[-0-9.eE]+"),
    K  = str_match(cv_line, "CV error \\(K=(\\d+)\\)")[,2] |> as.integer(),
    CV = str_match(cv_line, ":\\s*([-0-9.eE]+)")[,2] |> as.numeric()
  ) %>%
  select(file, K, CV) %>%
  arrange(K)
cv_df

#####try running multiple times and comparing output



###
library(adegenet)
library(vcfR)

#load sosp vcf file
vcf <- read.vcfR(file = "../data/Mikles_et_al._SongSparrows_MolecularEcology2020.vcf", verbose = TRUE)

#reformat the vcf file as genind
dna <- vcfR2DNAbin(vcf, unphased_as_NA = F, consensus = T, extract.haps = F)
species_genind <- DNAbin2genind(dna)
species_genind

# "157 individuals; 679 loci; 1,358 alleles"

#To make PCA behave properly with genotype data, we need to find some way to 
#treat missing data and center genotypes (i.e., make alternate homozygotes 
#equivalent, not translate to numeric values of 0 or 2 based on their allele 
#counts). We do so with the scaleGen() function, after which we can run PCA with 
#the prcomp() function:
species_genind_scaled <- scaleGen(species_genind,NA.method="mean",scale=F)
species_pca <- prcomp(species_genind_scaled, center=F,scale=F)

#now create a scree plot
#A “screeplot” displays the loadings of each principal component, indicating 
#whether the majority of variation in your data can be captured on a single 
#axis or not:
screeplot(species_pca)

#now PCA it
#extract the first few PCs and add sample names to the resulting dataframe:
pc <- data.frame(species_pca$x[,1:3])
pc$sample <- rownames(pc)

#quick plot
ggplot(data=pc,aes(x=PC1,y=PC2))+
  geom_text(aes(label=sample))

#Before we apply DAPC(#discriminant analysis of principal components), we need 
#some sort of a priori group assignment. We can do 
#this via -means clustering—an unsupervised machine learning algorithm that 
#partitions samples into distinct, nonoverlapping clsuters based on similarity 
#in PC space—using adegenet’s built-in find.clusters() function:
grp <- find.clusters(species_genind, n.pca = 50, n.clust = 2)
grp

#assign color and replot
pc$cluster <- grp$grp
ggplot(pc, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point(size = 2) +
  geom_text(aes(label = sample), vjust = -0.5, size = 3) 

#now run DAPC, which DAPC takes these hard-coded assignments and determines 
#which principal components contribute to them, as well as any uncertainty in 
#ancestry. (It is thus designed to discriminate on the basis of user-input 
#populations, and should be used in combination with -means clustering or other 
#approaches for detecting and / or designating structure.)

dapc1 <- dapc(species_genind, pop = grp$grp, n.pca = 50, n.da = 2)
dapc1

#The important part of this output are the posterior probabilities of ancestry 
#assignments. We will extract these and turn it into a tibble with sample name, 
#cluster, and ancestry probability:
q <- as.data.frame(dapc1$posterior)
q$sample <- rownames(q)
q_long <- q |>
  pivot_longer(
    cols = -sample,
    names_to = "cluster",
    values_to = "ancestry"
  )
q_long

#this can be plotted similarly to admixture
ggplot(q_long, aes(x = sample, y = ancestry, fill = cluster)) +
  geom_col(width = 1, color = "white") +
  theme_bw() +
  labs(x = "Individual", y = "Assignment probability") +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)
  )

#The final wrinkle we will address is how to compare results across different 
#values of K

# identify clusters
grp_auto <- find.clusters(
  species_genind,
  n.pca = 50,
  choose.n.clust = FALSE, 
  max.n.clust = 10,
  stat = "BIC"
)

# print BIC values
grp_auto$Kstat

#plot
plot(
  1:length(grp_auto$Kstat),
  grp_auto$Kstat,
  type = "b",
  xlab = "K",
  ylab = "BIC"
)

#In the above plot, K=2 seems to be the elbow despite the study working with 6
#differentiated SOSP populations

##################
#hw assignment 
##################

#the goal of the hw is to conduct the analysis again with other values of K

#ou should then compare a) individual ancestry proportions and 
#b) cross-validation / BIC values between its output and DAPC, and discuss your 
#findings. How you do this is up to you, but paired barplots (or even tables) 
#would likely do then trick.

#the starting point of the R-portion of this assignment is after you've generated
#your .fam.

#so first use an sbatch loop in terminal to create multiple output files

#now, run admixture and plotting in a loop, creating plots corresponding to K=2
# to K=6

#this script loops through for each K value, loading each respective .out
#and Q file

install.packages("patchwork")
library(patchwork)

# read sample names once
fam <- read_table("../scripts/sosp.int.fam",
                  col_names = FALSE,
                  show_col_types = FALSE)

samples <- fam$X2

# read K = 6 as reference
q_ref <- read_table("../scripts/sosp.int.6.Q",
                    col_names = FALSE,
                    show_col_types = FALSE)

K_ref <- ncol(q_ref)

colnames(q_ref) <- paste0("Cluster", 1:K_ref)

# order individuals by dominant ancestry + clustering
hc <- hclust(dist(q_ref))

sample_order <- samples[hc$order]

#########

plots <- list()

for (K in 2:6) {
  
  q <- read_table(paste0("../scripts/sosp.int.", K, ".Q"),
                  col_names = FALSE,
                  show_col_types = FALSE)
  
  colnames(q) <- paste0("Cluster", 1:K)
  
  q_df <- q %>%
    mutate(sample = samples) %>%
    mutate(sample = factor(sample, levels = sample_order))  # FIXED ORDER
  
  q_long <- q_df %>%
    pivot_longer(
      cols = starts_with("Cluster"),
      names_to = "cluster",
      values_to = "ancestry"
    )
  
  ####PLOT IT
  p <- ggplot(q_long, aes(x = sample, y = ancestry, fill = cluster)) +
    geom_col(width = 1, color = "white") +
    theme_bw() +
    labs(title = paste("K =", K),
         x = NULL,
         y = NULL) +
    theme(
      panel.grid = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      legend.position = "none"   # <-- MUST be here
    )
  
  plots[[as.character(K)]] <- p
}

###plot using patchwork packaage


series <- wrap_plots(plots, ncol = 1)

### save

ggsave(
  "series.plot.png",
  plot = series,
  width = 10,
  height = 12,
  dpi = 300
)

####
####
#Now lets get a table together to compare cross-validation / BIC values between 
#its output and DAPC

#try to use a loop again:

# read sample names once
fam <- read_table("../scripts/sosp.int.fam",
                  col_names = FALSE,
                  show_col_types = FALSE)

samples <- fam$X2

#load k values

ks <- 2:6

cv_table <- map_df(ks, function(K) {
  
  log_file <- paste0("../scripts/sosp.log", K, ".out")
  
  lines <- readLines(log_file)
  
  # get exact CV line
  cv_line <- lines[str_detect(lines, "CV error")]
  
  # extract number after colon
  cv_value <- str_extract(cv_line, "(?<=: )[0-9.]+") %>% as.numeric()
  
  tibble(K = K, CV_error = cv_value)
})

cv_table

#lets turn your cross-val table into a .png for your outputs
library(gridExtra)

grid.table(cv_table)

#save
png("cv_table.png", width = 600, height = 400)
grid.table(cv_table)
dev.off()

###########Now lets use DAPC so we can compare these two approaches

###First we'll repeat the steps from above to get our scree and PCA plots
###this does not use any values of K

#load sosp vcf file
vcf <- read.vcfR(file = "../data/Mikles_et_al._SongSparrows_MolecularEcology2020.vcf", verbose = TRUE)

#reformat the vcf file as genind
dna <- vcfR2DNAbin(vcf, unphased_as_NA = F, consensus = T, extract.haps = F)
species_genind <- DNAbin2genind(dna)
species_genind

# "157 individuals; 679 loci; 1,358 alleles"

#To make PCA behave properly with genotype data, we need to find some way to 
#treat missing data and center genotypes (i.e., make alternate homozygotes 
#equivalent, not translate to numeric values of 0 or 2 based on their allele 
#counts). We do so with the scaleGen() function, after which we can run PCA with 
#the prcomp() function:
species_genind_scaled <- scaleGen(species_genind,NA.method="mean",scale=F)
species_pca <- prcomp(species_genind_scaled, center=F,scale=F)

#now create a scree plot
#A “screeplot” displays the loadings of each principal component, indicating 
#whether the majority of variation in your data can be captured on a single 
#axis or not:
screeplot(species_pca)

# save scree plot for outputs:
png("screeplot.png", width = 800, height = 600)

screeplot(species_pca)

dev.off()

#now PCA it
#extract the first few PCs and add sample names to the resulting dataframe:
pc <- data.frame(species_pca$x[,1:3])
pc$sample <- rownames(pc)

#quick plot
ggplot(data=pc,aes(x=PC1,y=PC2))+
  geom_text(aes(label=sample))

#Before we apply DAPC(#discriminant analysis of principal components), we need 
#some sort of a priori group assignment. We can do 
#this via -means clustering—an unsupervised machine learning algorithm that 
#partitions samples into distinct, nonoverlapping clsuters based on similarity 
#in PC space—using adegenet’s built-in find.clusters() function:
grp <- find.clusters(species_genind, n.pca = 50, n.clust = 2)
grp

#assign color and replot
pc$cluster <- grp$grp

p <- ggplot(pc, aes(PC1, PC2, color = cluster)) +
  geom_point(size = 2) +
  theme_bw()

ggsave("pca.cluster.png", plot = p, width = 8, height = 6, dpi = 300)

####
####
grp_auto <- find.clusters(
  species_genind,
  n.pca = 50,
  choose.n.clust = FALSE,
  max.n.clust = 10
)

#extract bic values
bic_vals <- grp_auto$Kstat

#plot
plot(bic_vals, type = "b",
     xlab = "K",
     ylab = "BIC")

######now run DAPC in a loop for dif K values
dapc_list <- list()

for (k in 2:maxK) {
  
  grp <- find.clusters(
    species_genind,
    n.pca = 50,
    n.clust = k,
    choose.n.clust = FALSE
  )
  
  dapc_list[[as.character(k)]] <- dapc(
    species_genind,
    pop = grp$grp,
    n.pca = 50,
    n.da = min(k - 1, 5)
  )
}

#as in the lab above: #The important part of this output are the posterior 
#probabilities of ancestry assignments. We will extract these and turn it into a tibble with sample name, 
#cluster, and ancestry probability:

#######extract q-like values

dapc_q_list <- list()

for (k in 2:maxK) {
  
  dapc_obj <- dapc_list[[as.character(k)]]
  
  q <- as.data.frame(dapc_obj$posterior)
  q$sample <- rownames(q)
  
  q_long <- q %>%
    pivot_longer(
      cols = -sample,
      names_to = "cluster",
      values_to = "ancestry"
    )
  
  dapc_q_list[[as.character(k)]] <- q_long
}

##plot

for (k in 2:maxK) {
  
  q_long <- dapc_q_list[[as.character(k)]]
  
  p <- ggplot(q_long, aes(x = sample, y = ancestry, fill = cluster)) +
    geom_col(width = 1, color = "white") +
    theme_bw() +
    labs(
      title = paste("DAPC K =", k),
      x = NULL,
      y = "Assignment probability"
    ) +
    theme(
      panel.grid = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      legend.position = "none"
    )
  
  plots[[as.character(k)]] <- p
}

wrap_plots(plots, ncol = 2)

ggsave(
  "DAPC_multiK.png",
  wrap_plots(plots, ncol = 1),
  width = 10,
  height = 12,
  dpi = 300
)

###
grp_auto <- find.clusters(
  species_genind,
  n.pca = 50,
  choose.n.clust = FALSE,
  max.n.clust = 10
)

bic_df <- data.frame(
  K = 1:length(grp_auto$Kstat),
  BIC = grp_auto$Kstat
)

ggplot(bic_df, aes(K, BIC)) +
  geom_line() +
  geom_point() +
  theme_bw()

