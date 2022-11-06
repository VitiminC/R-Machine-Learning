rm(list = ls())

setwd("C:/Users/Bluep/Desktop/")

library(data.table)
library(caret)
library(Metrics)

#Test and training Datasets
testData <- fread('./HouseModel/Stat_380_test.csv')
trainingData <- fread('./HouseModel/Stat_380_train.csv')


testData
trainingData

#Setting key for quality and price
setkey(trainingData,OverallQual,SalePrice)

#subsetting the data to only consider the overall quaility of the house and price
sub_dat <- trainingData[!is.na(trainingData$SalePrice)][,.(OverallQual,SalePrice)]

sub_dat

prices <- trainingData[,.(Average_Sale_Price = mean(SalePrice)), by = OverallQual]
prices

setkey(prices, OverallQual)
setkey(testData, OverallQual)
testData <- merge(testData, prices, all.x =T)

predictions <- testData[,.(Id,Average_Sale_Price)]
predictions
write.csv(predictions,'./HouseModel/predictions.csv', row.names = FALSE)
