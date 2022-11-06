rm(list = ls())
library(data.table)

#data wrangling to submission form
predictions <- fread("./SubredditClassification/project/volume/data/interim/pred.csv")
testC <- fread("./SubredditClassification/project/volume/data/interim/testC.csv")

testID <- subset(testC, select = c(id))

predictions1 <- as.data.frame(split(predictions, 1:10))

submit <- cbind(testID, predictions1)


submit <- setnames(submit, c("pred", "pred.1", "pred.2", "pred.3", "pred.4", "pred.5", "pred.6", "pred.7", "pred.8", "pred.9")
                   , c("subredditcars", "subredditCooking", "subredditMachineLearning", "subredditmagicTCG", "subredditpolitics", "subredditReal_Estate", "subredditscience", "subredditStockMarket", "subreddittravel", "subredditvideogames"))

fwrite(submit,"./SubredditClassification/project/volume/data/interim/submit.csv")
