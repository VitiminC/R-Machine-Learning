rm(list=ls())

#creates the master table
source("./SubredditClassification/project/src/features/Cbind.R")

#generates the pca on the master table
source("./SubredditClassification/project/src/features/pca.R")

#all 3 Rtsne on the pca set
source("./SubredditClassification/project/src/features/Rtsne.R")
source("./SubredditClassification/project/src/features/Rtsne2.R")
source("./SubredditClassification/project/src/features/Rtsne3.R")

#combines all 3 rtsne sets and pca then splits them into train and test
source("./SubredditClassification/project/src/features/RtsneBinding.R")

#runs xgb on the combined set
source("./SubredditClassification/project/src/features/XGB.R")

#wrangled for submission
source("./SubredditClassification/project/src/features/PredictionWrangling.R")


#Tuning Table
Parameters <- fread("./SubredditClassification/project/volume/data/interim/Tuning2.csv")
View(Parameters)
