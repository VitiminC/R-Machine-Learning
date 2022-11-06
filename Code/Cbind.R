rm(list = ls())

library(data.table)

test_data <- fread("./SubredditClassification/project/volume/data/raw/test_file.csv")
test_emb <- fread("./SubredditClassification/project/volume/data/raw/test_emb.csv")
train_data <- fread("./SubredditClassification/project/volume/data/raw/train_data.csv")
train_emb <- fread("./SubredditClassification/project/volume/data/raw/train_emb.csv")

#combine the embeddings and test/train data
testC <- cbind(test_data, test_emb)
fwrite(testC,"./SubredditClassification/project/volume/data/interim/testC.csv")

train <- cbind(train_data, train_emb)

trainID <- subset(train, select = c("id","text"))

trainN <- setnames(train_data, c("subredditcars", "subredditCooking", "subredditMachineLearning", "subredditmagicTCG", "subredditpolitics", "subredditReal_Estate", "subredditscience", "subredditStockMarket", "subreddittravel", "subredditvideogames")
         , c("0","1","2","3","4","5","6","7","8","9"))


mtrain <- melt(trainN, id.vars = c("id","text"),
              measure.vars = c(3,4,5,6,7,8,9,10,11,12))

mtrain1 <- mtrain[mtrain$value != 0 ]

mtrain2 <- subset(mtrain1, select = c("text", "variable"))

temp <- merge(trainID, mtrain2, by = "text", sort = FALSE)

trainF <- subset(temp, select = c("id","text","variable"), stringsAsFactors = FALSE)

trainF <- setnames(trainF, "variable", "subreddit")

trainC <- cbind(trainF, train_emb)

fwrite(trainC,"./SubredditClassification/project/volume/data/interim/trainC.csv")

trainC$set <- 0
testC$set <- 1
testC$subreddit <- 11

#combining both train and test into one for pca/rtsne
masterC <- rbind(trainC, testC)
fwrite(masterC,"./SubredditClassification/project/volume/data/interim/masterC.csv")
