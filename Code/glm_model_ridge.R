rm(list=ls())

library(data.table)
library(caret)
library(Metrics)
library(glmnet)
library(plotmo)
library(lubridate)

test <- fread("./NCAA2021Predictions/project/volume/data/interim/Dtest.csv")
train <- fread("./NCAA2021Predictions/project/volume/data/interim/Dtrain.csv")

train <- na.omit(train)


train_G <- train[,.(Team1,Team2,Season,DayNum)]
test_G <- test[,.(Team1,Team2,Season,DayNum)]

train_T <- train[,.(POM_dif, SAG_dif, MOR_dif, DOK_dif, DScore, DOT, DFGM, DFGM3,DFGA, DFGA3, DFTM, DFTA, DOR, DDR, DTO,DStl,DWBlk,DPF)]
test_T <- test[,.(POM_dif, SAG_dif, MOR_dif, DOK_dif, DScore, DOT, DFGM, DFGM3,DFGA, DFGA3, DFTM, DFTA, DOR, DDR, DTO,DStl,DWBlk,DPF)]


train_y <- train$Result
test_y <- test_T$Result


#train_y <- na.omit(train_y)

#dummies <- dummyVars(Result ~ ., data=train)

#train <- predict(dummies, newdata = train)
#test <- predict(dummies, newdata = test)

#train_T <- data.table(train_T)
#test_T <- data.table(test_T)
#train$Result <- train_y



#glmnet
train_T <- as.matrix(train_T)
test_T <- as.matrix(test_T)
gl_model <- cv.glmnet(train_T, train_y, alpha = 0, family="binomial")
bestlam <- gl_model$lambda.min

gl_model <- glmnet(train_T, train_y, alpha = 0, family = "binomial")

pred <- predict(gl_model, s = bestlam, newx = test_T, type ="response")

test_T <- as.data.frame(test_T)

test_T$Result <- pred

#glm_fit <- glm(Result ~DAst, family = "binomial", data = train)
#test$Result <- predict(glm_fit,newdata = test, type ="response")

test_T$id <- paste(test$Season,"_",test$Team1,"_", test$Team2, sep="")
submit <- subset(test_T, select = c(id, Result))
setnames(submit, c("Result"), c("Pred"))


fwrite(submit,"./NCAA2021Predictions/project/volume/data/interim/submit2021Ridge.csv")
