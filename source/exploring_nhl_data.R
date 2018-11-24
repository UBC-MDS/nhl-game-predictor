# R script for exploratory data analysis for NHL game_teams_stats.csv data

library(tidyverse)

#! /usr/bin/env Rscript 
# exploring_nhl_data.R
# Aditya, Shayne, Nov 2018
#
# R script for exploring cleaned data from data/train.csv and generating exhibits
# The script takes an input file and names of output files for figures as arguments
# Usage: Rscript source/exploring_nhl_data.R data/train.csv imgs/fig1.jpg ##############

# loading the required libraries
library(tidyverse)

# getting cmd arguments into variables
args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
output_file_fig1 <- args[2]

# uncomment these lines if not running via shell
#input_file <- "data/train.csv"
#output_file_fig1 <- "imgs/fig1.jpg"

# reding the input
nhl_data <- read_csv(input_file)

# split data by target = TRUE/FALSE (won.x)
# nhl_data_won <- nhl_data %>% 
#     filter(won.x = TRUE)
# 
# nhl_data_lost <- nhl_data %>% 
#   filter(won.x = FALSE)

nhl_data %>% 
  ggplot(aes(x = won_prev10.diff)) +
    #geom_histogram(bins=15) +
    geom_density(aes(group=won.x, colour=won.x)) +
    theme_minimal() +

ggsave(output_file_fig1)
