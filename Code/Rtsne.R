rm(list = ls())

library(data.table)
library(ClusterR)
library(ggplot2)
library(caret)
library(Rtsne)



data <- fread("./SubredditClassification/project/volume/data/interim/pcaCMaster.csv")


#Saving ID column for later
full_id <- subset(data, select = c(id))
subreddit <- data$subreddit
data <- subset(data, select = -c(id, subreddit))

#rtsne on the pca dataset
tsne_dat <- Rtsne(data,
                  dims = 3,
                  pca = F,
                  perplexity = 5,
                  check_duplicates = F,
                  max_iter = 1500,
                  stop_lying_iter = 300
)

tsne_dat2 <- data.table(tsne_dat$Y)

best_clus_num <- 10
gmm_clusters <- GMM(tsne_dat2[,.(V1,V2,V3)],best_clus_num)

temp <- predict_GMM(tsne_dat2[,.(V1,V2,V3)],
                    gmm_clusters$centroids,
                    gmm_clusters$covariance_matrices,
                    gmm_clusters$weights)

temp <- temp$cluster_proba

temp <- data.table(temp)

temp$id <- full_id

RtsneC <- temp
RtsneC$subreddit <- subreddit
fwrite(RtsneC,"./SubredditClassification/project/volume/data/interim/RtsneC.csv")

