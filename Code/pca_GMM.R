rm(list = ls())

library(data.table)
library(ClusterR)
library(ggplot2)
library(caret)



set.seed(67)

data <- fread("./Identifying_S/project/volume/data/raw/data.csv")
example <- fread("./Identifying_S/project/volume/data/raw/example_solution.csv")

#Saving ID column for later
full_id <- subset(data, select = c(id))
data2 <- data.table(matrix(unlist(strsplit(data$id,"_")),ncol=2,byrow=T))
sample <- subset(data2, select = c(V1))
data <- subset(data, select = -c(id))


pca <- prcomp(data)
screeplot(pca)
biplot(pca)

pca_dt <- data.table(unclass(pca)$x)

# Finding desired number of clusters
max_to_consider <- 3
k_aic <- Optimal_Clusters_GMM(pca_dt[,1:3],
                              max_clusters = max_to_consider,
                              criterion = "AIC")

delta_k <- c(NA,k_aic[-1] - k_aic[-length(k_aic)])
del_k_tab <- data.table(delta_k=delta_k, k=1:length(delta_k))

#ggplot(del_k_tab, aes(x=k, y=-delta_k))+
  #geom_point()

#gmm clustering+predicting into probabilities
best_clus_num <- 3
gmm_clusters <- GMM(pca_dt[,1:3],3)

temp <- predict_GMM(pca_dt[,1:3],
            gmm_clusters$centroids,
            gmm_clusters$covariance_matrices,
            gmm_clusters$weights)

#wrangling data into submission form
temp <- temp$cluster_proba

temp <- data.table(temp)

temp$id <- full_id

temp <- temp[ , c(4, 3, 2, 1)]  

setnames(temp,c("V3","V2","V1"),c("breed.1","breed.2","breed.3"))


pcaGMMsubmit <- temp
fwrite(pcaGMMsubmit,"./Identifying_S/project/volume/data/interim/pcaGMMsubmit.csv")
























