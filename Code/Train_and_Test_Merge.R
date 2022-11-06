rm(list=ls())

#training <- fread("./NCAA2021Predictions/project/volume/data/interim/train_bind.csv")
training <- fread("./NCAA2021Predictions/project/volume/data/interim/train.csv")
stats_by_day <- fread("./NCAA2021Predictions/project/volume/data/interim/stats_by_day.csv")


#test <- fread("./NCAA2021Predictions/project/volume/data/raw/examp_sub.csv")
test <- fread("./NCAA2021Predictions/project/volume/data/interim/test.csv")



temp <- merge(training, stats_by_day, by.x = c("Team1", "Season", "DayNum"),
              by.y = c("TeamID", "Season", "DayNum"), all.x = T, sort = FALSE)

train_Merge <- merge(temp, stats_by_day, by.x = c("Team2", "Season", "DayNum"),
                     by.y = c("TeamID", "Season", "DayNum"), all.x = T, sort = FALSE)

fwrite(train_Merge,"./NCAA2021Predictions/project/volume/data/interim/train_Merge.csv")


#test <- tidyr::separate(test, id, into = c("Team1","Team2"))


#test$Team1 <- as.integer(as.character(test$Team1))
#test$Team2 <- as.integer(as.character(test$Team2))

#test$Season = 2019
#test$DayNum = 132

temp2 <- merge(test, stats_by_day, by.x = c("Team1", "Season", "DayNum"),
                     by.y = c("TeamID", "Season", "DayNum"), all.x = T, sort = FALSE)

test_Merge <- merge(temp2, stats_by_day, by.x = c("Team2", "Season", "DayNum"),
                    by.y = c("TeamID", "Season", "DayNum"), all.x = T, sort = FALSE)



test_Merge <- subset(test_Merge, select = -Result)


fwrite(test_Merge,"./NCAA2021Predictions/project/volume/data/interim/test_Merge.csv")






























