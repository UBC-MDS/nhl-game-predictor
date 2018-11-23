#! /usr/bin/env Rscript 
# cleaning_nhl_data.R
# Aditya, Shayne, Nov 2018
#
# R script for reading and cleaning data from game_teams_stats.csv file.
# The script takes an input file and names of output train and test file as arguments
# The specific team for which the analysis is being done needs to be provided  as the last arguement
# Usage: Rscript source/cleaning_nhl_data.R data/game_teams_stats.csv data/train.csv data/test.csv 23


# loading the required libraries
library(tidyverse)
library(zoo)

# getting cmd arguments into variables
args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
output_file_train <- args[2]
output_file_test <- args[3]
team_of_interest <- as.integer(args[4])

# reding the input
nhl_data <- read_csv(input_file)

# getting the columns with missing values
nhl_data_missing <- nhl_data %>% 
    select_if(function(x) any(is.na(x))) %>% 
    summarise_all(funs(sum(is.na(.))))

# getting the columns with empty values
nhl_data_empty <- nhl_data %>% 
    select_if(function(x) any(x == "")) %>% 
    summarise_all(funs(sum(. == "")))

# getting information by season
nhl_data_req <- nhl_data %>% 
  arrange(game_id) %>% 
  mutate(season = str_sub(game_id, start = 1, end = 4),
         reg_season = str_sub(game_id, start = 5, end = 6)) %>% 
  group_by(season, reg_season) %>% 
  filter(reg_season == "02")

# removing first half-played season
nhl_data_req <- nhl_data_req %>% 
  left_join(nhl_data, by = c("game_id" = "game_id")) %>% 
  filter(team_id.x != team_id.y, season != "2012")

# creating new features for the model
nhl_data_ready <- nhl_data_req %>% 
  arrange(team_id.x, game_id) %>% 
  group_by(team_id.x, season) %>% 
  mutate(won_prev1 = rollapply(won.x, mean, align='right', fill=NA, width = list(-1:-1)),
         won_prev3 = rollapply(won.x, mean, align='right', fill=NA, width = list(-3:-1)),
         won_prev5 = rollapply(won.x, mean, align='right', fill=NA, width = list(-5:-1)),
         won_prev10 = rollapply(won.x, mean, align='right', fill=NA, width = list(-10:-1)),
         
         shots_ratio = shots.x / (shots.x + shots.y),
         goals_ratio = goals.x / (goals.x + goals.y),
         save_ratio = 1 - goals.y / shots.y,
         
         shots_ratio_prev1 = rollapply(shots_ratio, mean, align='right', fill=NA, width = list(-1:-1)),
         shots_ratio_prev3 = rollapply(shots_ratio, mean, align='right', fill=NA, width = list(-3:-1)),
         shots_ratio_prev5 = rollapply(shots_ratio, mean, align='right', fill=NA, width = list(-5:-1)),
         shots_ratio_prev10 = rollapply(shots_ratio, mean, align='right', fill=NA, width = list(-10:-1)),
         
         goals_ratio_prev1 = rollapply(goals_ratio, mean, align='right', fill=NA, width = list(-1:-1)),
         goals_ratio_prev3 = rollapply(goals_ratio, mean, align='right', fill=NA, width = list(-3:-1)),
         goals_ratio_prev5 = rollapply(goals_ratio, mean, align='right', fill=NA, width = list(-5:-1)),
         goals_ratio_prev10 = rollapply(goals_ratio, mean, align='right', fill=NA, width = list(-10:-1)),
         
         save_ratio_prev1 = rollapply(save_ratio, mean, align='right', fill=NA, width = list(-1:-1)),
         save_ratio_prev3 = rollapply(save_ratio, mean, align='right', fill=NA, width = list(-3:-1)),
         save_ratio_prev5 = rollapply(save_ratio, mean, align='right', fill=NA, width = list(-5:-1)),
         save_ratio_prev10 = rollapply(save_ratio, mean, align='right', fill=NA, width = list(-10:-1))) %>% 
  drop_na() %>% 
  select(game_id, season, team_id = team_id.x, 
         shots_ratio_prev1, shots_ratio_prev3, shots_ratio_prev5, shots_ratio_prev10, 
         goals_ratio_prev1, goals_ratio_prev3, goals_ratio_prev5, goals_ratio_prev10,
         won_prev1, won_prev3, won_prev5, won_prev10,
         save_ratio_prev1, save_ratio_prev3, save_ratio_prev5, save_ratio_prev10)

# adding opponent information
nhl_data_ready <- nhl_data_ready %>% 
  left_join(nhl_data_ready, by = c("game_id" = "game_id")) %>% 
  filter(team_id.x != team_id.y) %>% 
  filter(team_id.x == team_of_interest) %>% 
  group_by(season.x)

# creating training data
nhl_data_train <- nhl_data_ready %>% 
  filter(season.x != "2017")

# craeting test data
nhl_data_test <- nhl_data_ready %>% 
    filter(season.x == "2017")

# writing the train and the test data to csv files
write_csv(nhl_data_ready, output_file_train)
write_csv(nhl_data_test, output_file_test)

