rm(list = ls())
library(data.table)
library(caret)
library(xgboost)

#set.seed(1234567) Best error so far


trainC <- fread("./SubredditClassification/project/volume/data/interim/combinedTrain.csv")
testC <- fread("./SubredditClassification/project/volume/data/interim/combinedTest.csv")

#some data wrangling to fit xgb
testC$subreddit <- as.integer(0)

trainID <- subset(trainC, select = c(id))
trainCsplit <- subset(trainC, select = -c(id, subreddit))
train_label <- subset(trainC, select = c(subreddit))

testID <- subset(testC, select = c(id))
testCsplit  <- subset(testC, select = -c(id, subreddit))

train.y <- trainC$subreddit
test.y <- testC$subreddit


trainCmatrix <- data.matrix(trainCsplit)
testCmatrix <- data.matrix(testCsplit)




dtrain <- xgb.DMatrix(trainCmatrix,label=train.y,missing=NA)

dtest <- xgb.DMatrix(testCmatrix,missing=NA)

hyper_perm_tune <- NULL

#setting arrays of values to test in parameter tuning
gamma1 <-c(0.1)
eta1 <- c(0.02, 0.1, 0.2, 0.4, 0.6)
max_depth1 <- c(6,8,10,12,14)
min_child_weight1 <- c(2,4,6,8)
subsample1 <- c(0.6)
colsample_bytree1 <- c(0.4, 0.6, 0.8, 0.8)
nfold1 <- c(4,7)
nrounds1 <- c(10000)

#for loop for parameter tuning
for (a in gamma1){
  for (b in eta1){
    for (c in max_depth1){
      for (d in min_child_weight1){
        for (e in subsample1){
          for (f in colsample_bytree1){
            for (g in nfold1){
              for (h in nrounds1){
                
                parameters <- list(objective = "multi:softprob",
                                   gamma = a, #minimum loss reduction required
                                   booster = "gbtree",
                                   eval_metric = "mlogloss",
                                   eta = b, #learning rate(default is 0.3), smaller eta the larger B is
                                   max_depth = c, #default is 6
                                   min_child_weight = d, #min num of observations
                                   subsample = e,  #ratio
                                   colsample_bytree = f, #ratio of parameters to consider
                                   tree_method = 'hist',
                                   num_class = 10)
                
                XGBfit <- xgb.cv(params = parameters,
                                 nfold = g,
                                 nrounds = h,
                                 missing = NA,
                                 data = dtrain,
                                 print_every_n = 1,
                                 early_stopping_rounds = 50)
                
                best_tree_n <- unclass(XGBfit)$best_iteration
                
                
                #trainCsplit$subreddit <- train.y
                new_row <- data.table(t(parameters))
                new_row$best_tree_n <- best_tree_n
                new_row$nfold <- g
                test_error <- unclass(XGBfit)$evaluation_log[best_tree_n,]$test_mlogloss_mean
                new_row$test_error <- test_error
                hyper_perm_tune <- rbind(new_row, hyper_perm_tune, fill=TRUE)
                
              }
            }
          }
        }
      }
    }
  }
}

tuning3 <- hyper_perm_tune
fwrite(tuning3,"./SubredditClassification/project/volume/data/interim/Tuning3.csv")
#new parameters after selecting the best one from the loop
parameters <- list(objective = "multi:softprob",
                   gamma = 0.1, #minimum loss reduction required
                   booster = "gbtree",
                   eval_metric = "mlogloss",
                   eta = 0.07, #learning rate(default is 0.3), smaller eta the larger B is
                   max_depth = 10, #default is 6
                   min_child_weight = 2, #min num of observations
                   subsample = 0.6,  #ratio
                   colsample_bytree = 0.8, #ratio of parameters to consider
                   tree_method = 'hist',
                   num_class = 10)

XGBfit <- xgb.cv(params = parameters,
                 nfold = 7,
                 nrounds = 10000,
                 missing = NA,
                 data = dtrain,
                 print_every_n = 1,
                 early_stopping_rounds = 50)

best_tree_n <- unclass(XGBfit)$best_iteration


#trainCsplit$subreddit <- train.y
new_row <- data.table(t(parameters))
new_row$best_tree_n <- best_tree_n
test_error <- unclass(XGBfit)$evaluation_log[best_tree_n,]$test_mlogloss_mean
new_row$test_error <- test_error
hyper_perm_tune <- rbind(new_row, hyper_perm_tune, fill=TRUE)


watchlist <- list(train=dtrain)

XGBfit <- xgb.train(params = parameters,
                    nrounds = best_tree_n,
                    missing = NA,
                    data = dtrain,
                    watchlist = watchlist,
                    print_every_n = 1,
                    early_stopping_rounds = 25)

pred <- predict(XGBfit, newdata = dtest)
pred <- data.frame(pred)
fwrite(pred,"./SubredditClassification/project/volume/data/interim/pred.csv")
