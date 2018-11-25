#! /usr/bin/env Rscript 
# exploring_nhl_data.R
# Aditya, Shayne, Nov 2018
#
# R script for exploring cleaned data from data/train.csv and generating exhibits
# The script takes an input file and names of output files for figures as arguments
# Usage: Rscript source/exploring_nhl_data.R data/train.csv imgs/fig-1_home-away.jpg home_game.x "Canucks Home Game?" TRUE "Figure 1: Impact of game location - home or away"

# loading the required libraries
library(tidyverse)
library(gridExtra)

# getting cmd arguments into variables
args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
output_file <- args[2]
x_var <- args[3]
x_lab <- args[4]
x_categorical <- args[5]
fig_title <- args[6]

# comment these lines if running via shell
# input_file <- "data/train.csv"
# output_file <- "imgs/fig-2_win-diff.jpg"
# x_var <- "won_prev1.diff"
# x_lab <- ""
# x_categorical <- FALSE
# fig_title <- "Figure 2: Difference of moving average wins ratio between Canucks and opponent \n Note: single feature density histogram, blue line is for games won by Canucks, red is for losses"

main <- function() {
  # reading the input data
  nhl_data <- read_csv(input_file)
  
  # call the  necessary plot functions
  if(x_categorical) {
    generate_plot_categorical(nhl_data)
  } else {
    generate_plot_row(nhl_data)
  }
}

# first figure: home or away
generate_plot_categorical <- function(data) {
  
  # subset just the data we need for plot
  plot_data <- data[c("won.x", x_var)]
  colnames(plot_data)[1] <- "won"
  colnames(plot_data)[2] <- "x"
  
  plot_data %>% 
    ggplot(aes(x = x, y = won)) +
    geom_bin2d() +
    labs(x=x_lab, y="Did Canucks win?",
         title = fig_title,
         subtitle = "Lighter blue indicates that this happens more often, darker less") +
    guides(fill = FALSE)  +
    theme_minimal()
  ggsave(output_file)
}

# function to generate row of plots for all moving averages
generate_plot_row <- function(data) {
  plot_data <- data[c("won.x", x_var)]
  colnames(plot_data)[1] <- "won"
  colnames(plot_data)[2] <- "x"
  plot1 <- generate_plot_numerical(plot_data, "previous 1-games")
  
  plot_data[2] <- data[,str_replace(x_var,"1","3")]
  plot3 <- generate_plot_numerical(plot_data, "previous 3-games")
  
  plot_data[2] <- data[,str_replace(x_var,"1","5")]
  plot5 <- generate_plot_numerical(plot_data, "previous 5-games")
  
  plot_data[2] <- data[,str_replace(x_var,"1","10")]
  plot10 <- generate_plot_numerical(plot_data, "previous 10-games")
  
  g <- arrangeGrob(nrow=1, plot1, plot3, plot5, plot10, 
                   top=paste(fig_title," \n Note: blue line is for games won by Canucks, red is for losses"))
  ggsave(file=output_file, g, width=200, height = 50, units = "mm")
}

# function to generate a single density plot for a given variable 
generate_plot_numerical <- function(data, title) {

  x_min = min(data[2])
  x_max = max(data[2])
  
  data %>% 
    ggplot(aes(x = x)) +
      geom_density(bw=0.2, aes(group=won, colour=won), show.legend=F) +
      xlim(x_min, x_max) +
      labs(x=x_lab,y="", caption=title) +
      theme_minimal()
}

# call main function
main()
