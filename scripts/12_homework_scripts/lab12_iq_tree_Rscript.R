#Jason Gregg
#Lab 12

setwd("bioe-591-genomics/students/jason-gregg/scripts")

# install.packages("ape")
library(ape)
library(readr)

# read tree
tree <- read.tree("lemurs.snps.min4.phy.contree")
tree
#Attributes of the tree object can be accessed with the $ operator, e.g.:
tree$tip.label

# read metadata
meta <- read_tsv("~/bioe-591-genomics/course-materials/data/phylogenetics/lemur_metadata.txt")

# map species to sample
map <- setNames(meta$species, meta$ID_long)

# overwrite tip labels
tree$tip.label <- unname(map[tree$tip.label])

plot(tree)

#Now need to root the tree with outgroup:
#To make this output more interpretable, we use the root() function and the name
#of Microcebus murinus sample. We can also add bootstrapped support values, 
#filtering to show only those that exceed 70 (a common cutoff for confidence 
#in the relationship portrayed by a node):

# root using an outgroup (replace with your sample name)
tree_rooted <- root(tree, outgroup = "murinus", resolve.root = TRUE)

# plot
plot(tree_rooted)

# add node labels
bs <- as.numeric(tree$node.label)
nodelabels(ifelse(bs >= 70, bs, ""), cex = 0.7, frame = "n")

#export your tree
png("lemur_tree.png", width = 1000, height = 800)
plot(tree_rooted)
nodelabels(tree$node.label, cex = 0.7, frame = "n")
dev.off()

