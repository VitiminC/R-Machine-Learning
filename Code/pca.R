rm(list = ls())

library(data.table)
library(ClusterR)
library(ggplot2)
library(caret)

data <- fread("./SubredditClassification/project/volume/data/interim/masterC.csv")

#Saving ID column for later
subreddit <- data$subreddit
full_id <- subset(data, select = c(id))
data <- subset(data, select = -c(id, text, subreddit))

pca <- prcomp(data)
screeplot(pca)
biplot(pca)

pca_dt <- data.table(unclass(pca)$x)

# Finding desired number of clusters
max_to_consider <- 10
k_aic <- Optimal_Clusters_GMM(pca_dt[,1:10],
                              max_clusters = max_to_consider,
                              criterion = "AIC")

delta_k <- c(NA,k_aic[-1] - k_aic[-length(k_aic)])
del_k_tab <- data.table(delta_k=delta_k, k=1:length(delta_k))

#ggplot(del_k_tab, aes(x=k, y=-delta_k))+
#geom_point()

#gmm clustering+predicting into probabilities
best_clus_num <- 10
gmm_clusters <- GMM(pca_dt[,1:10],10)

temp <- predict_GMM(pca_dt[,1:10],
                    gmm_clusters$centroids,
                    gmm_clusters$covariance_matrices,
                    gmm_clusters$weights)

#wrangling data into submission form
temp <- temp$cluster_proba

temp <- data.table(temp)

temp$id <- full_id

pcaC <- temp

pcaC$subreddit <- subreddit
fwrite(pcaC,"./SubredditClassification/project/volume/data/interim/pcaCMaster.csv")

pcaCTrain <- pcaC[0:200]
pcaCTest <- pcaC[201:20755]

fwrite(pcaCTrain,"./SubredditClassification/project/volume/data/interim/pcaCTrain.csv")
fwrite(pcaCTest,"./SubredditClassification/project/volume/data/interim/pcaCTest.csv")
