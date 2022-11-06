rm(list = ls())

library(caret)
library(data.table)
library(Metrics)


train <- fread('./project/volume/data/raw/Stat_380_train.csv')
test <- fread('./project/volume/data/raw/Stat_380_test.csv')

train_sub <- subset(train, select = -c(Id, LotFrontage,TotRmsAbvGrd,Heating,PoolArea,YrSold))
train_sub


train_y <- train_sub$SalePrice
test_y <- test$SalePrice

unique(train$CentralAir)

dummies <- dummyVars(SalePrice ~ ., data = train_sub)
dummies2 <- dummyVars(" ~ .", data = test)

train_sub <- predict(dummies, newdata = train_sub)
train_sub <- data.table(train_sub)

test <- predict(dummies2, newdata = test)
test <- data.table(test)

train_sub$SalePrice <- train_y

fit = lm(SalePrice ~., data = train_sub)

saveRDS(dummies,"./project/volume/models/SalePrice_lm.dummies")
saveRDS(fit,"./project/volume/models/SalePrice_lm.model")

fit
summary(fit)

test$SalePrice <- predict(fit, newdata = test)
submit <- test[,.(Id,SalePrice)]

submit$SalePrice[is.na(submit$SalePrice)] <- mean(submit$SalePrice,na.rm=TRUE)
submit

fwrite(submit,"./project/volume/data/processed/lm_prediction.csv")

