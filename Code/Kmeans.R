rm(list = ls())

library(data.table)
library(ClusterR)
library(ggplot2)

set.seed(46466)

data <- fread("./Identifying_S/project/volume/data/raw/data.csv")
example <- fread("./Identifying_S/project/volume/data/raw/example_solution.csv")

#Saving ID column
full_id <- subset(data, select = c(id))
data2 <- data.table(matrix(unlist(strsplit(data$id,"_")),ncol=2,byrow=T))
#data3 <- as.numeric(as.character(data2$V2))
#id <- data.table(data3)
sample <- subset(data2, select = c(V1))
data <- subset(data, select = -c(id))


pca <- prcomp(data)
screeplot(pca)
biplot(pca)

pca_dt <- data.table(unclass(pca)$x)

#all data
#kmeansCluster <- kmeans(data,3)

#some components
kmeansCluster <- kmeans(pca_dt[,1:3],3)

#gmm_clusters <- GMM(pca_dt[,1:3],3)


clusters <- data.table(unclass(kmeansCluster)$cluster)

clusters$id <- id

clusters <- subset(clusters, select = c(id, V1))

dcluster <- dcast(clusters, id~V1,value.var= "V1")

dcluster$id <- full_id
setnames(dcluster,c("1","2","3"),c("breed.1","breed.2","breed.3"))

dcluster$breed.2 <- replace(dcluster$breed2, dcluster$breed.2==2,1)
dcluster$breed.3 <- replace(dcluster$breed3, dcluster$breed.3==3,1)
dcluster[is.na(dcluster)]<-0


#log_L <- data.table(gmm_clusters$Log_likelihood)
#log_L <- exp(log_L)

submit <- dcluster
fwrite(submit,"./Identifying_S/project/volume/data/interim/submit.csv")
