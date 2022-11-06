rm(list = ls())

library(data.table)

RtsneC <- fread("./SubredditClassification/project/volume/data/interim/RtsneC.csv")
RtsneC2 <- fread("./SubredditClassification/project/volume/data/interim/RtsneC2.csv")
RtsneC3 <- fread("./SubredditClassification/project/volume/data/interim/RtsneC3.csv")
pcaTrain <- fread("./SubredditClassification/project/volume/data/interim/pcaCTrain.csv")
pcaTest <- fread("./SubredditClassification/project/volume/data/interim/pcaCTest.csv")

#data wrangling to combine all 3 Rtsne and pca sets
identity <- subset(RtsneC, select = c(id, subreddit))
RtsneC <- subset(RtsneC, select = -c(id, subreddit))
pcaTrain <- subset(pcaTrain, select = -c(id, subreddit))
pcaTest <- subset(pcaTest, select = -c(id, subreddit))

RtsneCombined <- cbind(RtsneC,RtsneC2)

RtsneCombined <- cbind(RtsneCombined,RtsneC3)

RtsneCombined <- cbind(identity, RtsneCombined)

RtsneTrain <- RtsneCombined[0:200]

RtsneTest <- RtsneCombined[201:20755]

combinedTrain <- cbind(RtsneTrain, pcaTrain)
combinedTest <- cbind(RtsneTest, pcaTest)


fwrite(combinedTrain,"./SubredditClassification/project/volume/data/interim/combinedTrain.csv")
fwrite(combinedTest,"./SubredditClassification/project/volume/data/interim/combinedTest.csv")
