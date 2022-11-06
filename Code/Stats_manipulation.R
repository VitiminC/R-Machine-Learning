rm(list=ls())

library(caret)
library(data.table)
library(Metrics)

regularseason <- fread("./NCAA2021Predictions/project/volume/data/raw/MRegularSeasonDetailedResults.csv")
tournygames <- fread("./NCAA2021Predictions/project/volume/data/raw/MNCAATourneyDetailedResults.csv")

all_games_table <- rbind(regularseason,tournygames)

W_stats <- all_games_table[,.(Season, DayNum, WTeamID, WScore, NumOT, WFGM, WFGA, WFGM3, WFGA3, WFTM, WFTA, WOR, WDR, WAst, WTO, WStl, WBlk, WPF)]
L_stats <- all_games_table[,.(Season, DayNum, LTeamID, LScore, NumOT, LFGM, LFGA, LFGM3, LFGA3, LFTM, LFTA, LOR, LDR, LAst, LTO, LStl, LBlk, LPF)]

setnames(W_stats, c("WTeamID", "WScore", "NumOT", "WFGM", "WFGA", "WFGM3", "WFGA3", "WFTM", "WFTA", "WOR", "WDR", "WAst", "WTO", "WStl", "WBlk", "WPF")
         , c("TeamID", "Score", "NumOT", "FGM", "FGA", "FGM3", "FGA3", "FTM", "FTA", "OR", "DR", "Ast", "TO", "Stl", "Blk", "PF"))

setnames(L_stats, c("LTeamID", "LScore", "NumOT", "LFGM", "LFGA", "LFGM3", "LFGA3", "LFTM", "LFTA", "LOR", "LDR", "LAst", "LTO", "LStl", "LBlk", "LPF")
         , c("TeamID", "Score", "NumOT", "FGM", "FGA", "FGM3", "FGA3", "FTM", "FTA", "OR", "DR", "Ast", "TO", "Stl", "Blk", "PF"))

master_stats <- rbind(W_stats,L_stats)
fwrite(master_stats,"./NCAA2021Predictions/project/volume/data/interim/master_stats.csv")


stats_by_day<-NULL

for (i in 1:max(master_stats$DayNum)){
  
  sub_master_stats <- master_stats[DayNum < i]
  team_stats_by_day <- dcast(sub_master_stats, TeamID+Season~.,mean,value.var=c("Score", "NumOT", "FGM", "FGA", "FGM3", "FGA3", "FTM", "FTA", "OR", "DR", "Ast", "TO", "Stl", "Blk", "PF"))
  
  team_stats_by_day$DayNum <- i
  
  stats_by_day<-rbind(stats_by_day,team_stats_by_day)
  
}


fwrite(stats_by_day,"./NCAA2021Predictions/project/volume/data/interim/stats_by_day.csv")

fwrite(all_games_table,"./NCAA2021Predictions/project/volume/data/interim/all_games_table.csv")

