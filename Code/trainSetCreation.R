#this code isn't used for the project, it has been contained in the MasseyOrdinals file.


rm(list=ls())

library(caret)
library(data.table)
library(Metrics)

parameters <- fread("./BasketballGames/project/volume/data/interim/stats_by_day.csv")

train <- fread("./BasketballGames/project/volume/data/interim/all_games_table.csv")
train2 <- train

#train$DScore <- train$WScore-train$LScore
#train$DFGM <- train$WFGM-train$LFGM
#train$DFGA <- train$WFGA-train$LFGA
#train$DFGM3 <- train$WFGM3-train$LFGM3
#train$DFGA3 <- train$WFGA3-train$LFGA3
#train$DFTM <- train$WFTM-train$LFTM
#train$DFTA <- train$WFTA-train$LFTA
#train$DOR <- train$WOR-train$LOR
#train$DDR <- train$WDR-train$LDR
#train$DAst <- train$WAst-train$LAst
#train$DTO <- train$WTO-train$LTO
#train$DStl <- train$WStl-train$LStl
#train$DWBlk <- train$WBlk-train$LBlk
#train$DPF <- train$WPF-train$LPF

train <- train[,.(WTeamID, LTeamID, Season, DayNum)]
#DScore, DFGM, DFGA, DFGM3, DFGA3, DFTM, DFTA, DOR, DDR, DAst, DTO, DStl, DWBlk, DPF

train$Result=1

setnames(train, c("WTeamID", "LTeamID"), c("Team1", "Team2"))

#train2$DScore <- train2$LScore-train2$WScore
#train2$DFGM <- train2$LFGM-train2$WFGM
#train2$DFGA <- train2$LFGA-train2$WFGA
#train2$DFGM3 <- train2$LFGM3-train2$WFGM3
#train2$DFGA3 <- train2$LFGA3-train2$WFGA3
#train2$DFTM <- train2$LFTM-train2$WFTM
#train2$DFTA <- train2$LFTA-train2$WFTA
#train2$DOR <- train2$LOR-train2$WOR
#train2$DDR <- train2$LDR-train2$WDR
#train2$DAst <- train2$LAst-train2$WAst
#train2$DTO <- train2$LTO-train2$WTO
#train2$DStl <- train2$LStl-train2$WStl
#train2$DWBlk <- train2$LBlk-train2$WBlk
#train2$DPF <- train2$LPF-train2$WPF

train2 <- train2[,.(LTeamID, WTeamID, Season, DayNum)]
#DScore, DFGM, DFGA, DFGM3, DFGA3, DFTM, DFTA, DOR, DDR, DAst, DTO, DStl, DWBlk, DPF

train2$Result=0

setnames(train2, c("LTeamID", "WTeamID"), c("Team1", "Team2"))

train_bind <- rbind(train,train2)

fwrite(train_bind,"./BasketballGames/project/volume/data/interim/train_bind.csv")
