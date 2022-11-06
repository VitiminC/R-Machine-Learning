rm(list = ls())
library(data.table)

test <- fread('./NCAA2021Predictions//project/volume/data/raw/MSampleSubmissionStage2.csv')
season <- fread('./NCAA2021Predictions//project/volume/data/raw/MRegularSeasonDetailedResults.csv')
tourney <- fread('./NCAA2021Predictions//project/volume/data/raw/MNCAATourneyDetailedResults.csv')
ranks <- fread('./NCAA2021Predictions//project/volume/data/raw/MMasseyOrdinals.csv')


#- Clean test

test <- data.table(matrix(unlist(strsplit(test$ID,"_")),ncol=3,byrow=T))
setnames(test,c("V1","V2","V3"),c("Season","Team1","Team2"))

#test$Season <- 2019
test$DayNum <- max(season[Season == 2021,DayNum]) + 1
test$Result <- 0.5

#- initializing train

train <- rbind(season,tourney)
train <- train[,.(WTeamID,LTeamID,Season,DayNum)]
setnames(train,c("WTeamID","LTeamID"),c("Team1","Team2"))

train$Result <- 1

#- make master data file

master <- rbind(train,test)

#- ensure my team ids are characters
master$Team1 <- as.character(master$Team1)
master$Team2 <- as.character(master$Team2)
master$Season <- as.integer(master$Season)

#- teams' rank often change the day of a game so don't want to use the 'future'
# values. we ofset them by one.
ranks$DayNum <- ranks$RankingDayNum+1

#- you should optimize the following by creating a list of the systems and 
#- creating a loop to add them into the table

which_system <- c("POM","SAG","MOR","DOK")

#- following is the list of the five systems you should use. Your mission, should 
# you decide to accept it is to turn the big chunk of code starting at line #48ish
# into a for loop to incorporate the five rankings
# which_system <- c("POM","PIG","SAG","MOR","DOK")

#- start here

for (i in which_system){
  

#- subset the ranks table
  one_rank <- ranks[SystemName == i][,.(Season,DayNum,TeamID,OrdinalRank)]

#- prep and join into the first team
  setnames(one_rank,"TeamID","Team1")
  one_rank$Team1 <- as.character(one_rank$Team1)
  setkey(master,Season,Team1,DayNum)
  setkey(one_rank,Season,Team1,DayNum)

#- join here
  master <- one_rank[master,roll=T]
  setnames(master,"OrdinalRank","Team1_rank")


#- prep and merge into the second team
  setnames(one_rank,"Team1","Team2")
  setkey(master,Season,Team2,DayNum)
  setkey(one_rank,Season,Team2,DayNum)

  master <- one_rank[master,roll=T]
  setnames(master,"OrdinalRank","Team2_rank")

#subtract the rankings for a new variable
  master$rank_dif <- master$Team2_rank-master$Team1_rank

  master$Team1_rank <- NULL
  master$Team2_rank <- NULL
  setnames(master,"rank_dif",paste0(i,"_dif"))

# end here
}


#- clean up the data
master <- master[order(Season,DayNum)]


#- get rid of id variables and nas ( you should keep the ids, Season and Day)

master <- master[,.(Team1,Team2,Season,DayNum,POM_dif, SAG_dif, MOR_dif, DOK_dif, Result)]
#master <- master[!is.na(master$POM_dif)]
master <- na.omit(master)

#split back into train and test
test <- master[Result == 0.5]
train <- master[Result == 1]

#- divide so I have losses 
rand_inx <- sample(1:nrow(train),nrow(train)*0.5)
train_a <- train[rand_inx,]
train_b <- train[!rand_inx,]


#which_system <- c("POM","PIG","SAG","MOR","DOK")
#- train_b will encode the loses
train_b$Result <- 0
train_b$POM_dif <- train_b$POM_dif*-1
#train_b$PIG_dif <- train_b$PIG_dif*-1
train_b$SAG_dif <- train_b$SAG_dif*-1
train_b$MOR_dif <- train_b$MOR_dif*-1
train_b$DOK_dif <- train_b$DOK_dif*-1

setnames(train_b,c("Team1","Team2"),c("Team2","Team1"))

train <- rbind(train_a,train_b)

fwrite(test,"./NCAA2021Predictions/project/volume/data/interim/test.csv")
fwrite(train,"./NCAA2021Predictions/project/volume/data/interim/train.csv")





