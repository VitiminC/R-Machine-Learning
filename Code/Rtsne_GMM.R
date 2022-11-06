rm(list = ls())

library(data.table)
library(ClusterR)
library(ggplot2)
library(caret)
library(Rtsne)


set.seed(67)

data <- fread("./Identifying_S/project/volume/data/raw/data.csv")
example <- fread("./Identifying_S/project/volume/data/raw/example_solution.csv")

#Saving ID column for later
full_id <- subset(data, select = c(id))
data2 <- data.table(matrix(unlist(strsplit(data$id,"_")),ncol=2,byrow=T))
sample <- subset(data2, select = c(V1))
data <- subset(data, select = -c(id))


tsne_dat <- Rtsne(data,
                  dims = 3,
                  pca = T,
                  perplexity = 30,
                  check_duplicates = F,
                  max_iter = 6000,
                  stop_lying_iter = 2500
                  )

tsne_dat2 <- data.table(tsne_dat$Y)

best_clus_num <- 3
gmm_clusters <- GMM(tsne_dat2[,.(V1,V2,V3)],best_clus_num)

temp <- predict_GMM(tsne_dat2[,.(V1,V2,V3)],
                    gmm_clusters$centroids,
                    gmm_clusters$covariance_matrices,
                    gmm_clusters$weights)

temp <- temp$cluster_proba

temp <- data.table(temp)

temp$id <- full_id

temp <- temp[ , c(4, 3, 2, 1)]  

setnames(temp,c("V3","V2","V1"),c("breed.1","breed.2","breed.3"))


RtsneGMMsubmit <- temp
fwrite(RtsneGMMsubmit,"./Identifying_S/project/volume/data/interim/RtsneGMMsubmit.csv")
