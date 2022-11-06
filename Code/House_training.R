rm(list = ls())

library(data.table)
library(caret)
library(xgboost)


test <- fread('./HousePricesNew/project/volume/data/raw/Stat_380_test.csv')
train <- fread('./HousePricesNew/project/volume/data/raw/Stat_380_train.csv')

test$SalePrice <- 0
#train <- na.omit(train)

train_sub <- subset(train, select = -c(Id))
train_sub
test_sub <- subset(test, select = -c(Id))

y.train <- train_sub$SalePrice
y.test <- test$SalePrice

dummies <- dummyVars(SalePrice ~ ., data = train_sub)

x.train <- predict(dummies, newdata = train_sub)
x.test <- predict(dummies, newdata = test)

dtrain <- xgb.DMatrix(x.train,label=y.train,missing=NA)

dtest <- xgb.DMatrix(x.test,missing=NA)

hyper_perm_tune <- NULL

parameters <- list(objective = "reg:squarederror",
                   gamma = 0.02, #minimum loss reduction required
                   booster = "gbtree",
                   eval_metric = "rmse",
                   eta = 0.02, #learning rate(default is 0.3), smaller eta the larger B is
                   max_depth = 5, #default is 6
                   min_child_weight = 2, #min num of observations
                   subsample = 0.9,  #ratio
                   colsample_bytree = 0.6, #ratio of parameters to consider
                   tree_method = 'hist')

XGBfit <- xgb.cv(params = parameters,
                 nfold = 5,
                 nrounds = 10000,
                 missing = NA,
                 data = dtrain,
                 print_every_n = 1,
                 early_stopping_rounds = 25)

best_tree_n <- unclass(XGBfit)$best_iteration


train_sub$SalePrice <- y.train
new_row <- data.table(t(parameters))
new_row$best_tree_n <- best_tree_n
test_error <- unclass(XGBfit)$evaluation_log[best_tree_n,]$test_rmse_mean
new_row$test_error <- test_error
hyper_perm_tune <- rbind(new_row, hyper_perm_tune)


watchlist <- list(train=dtrain)

XGBfit <- xgb.train(params = parameters,
                 nrounds = best_tree_n,
                 missing = NA,
                 data = dtrain,
                 watchlist = watchlist,
                 print_every_n = 1,
                 early_stopping_rounds = 25)

pred <- predict(XGBfit, newdata = dtest)

test$SalePrice <- pred
submit <- subset(test, select = c(Id, SalePrice))


fwrite(hyper_perm_tune,"./HousePricesNew/project/volume/data/interim/hyper_perm_tune.csv")
fwrite(submit,"./HousePricesNew/project/volume/data/interim/submit.csv")
