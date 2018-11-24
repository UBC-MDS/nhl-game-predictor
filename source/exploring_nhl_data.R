#! /usr/bin/env Rscript 
# exploring_nhl_data.R
# Aditya, Shayne, Nov 2018
#
# R script for exploring cleaned data from data/train.csv and generating exhibits
# The script takes an input file and names of output files for figures as arguments
# Usage: Rscript source/exploring_nhl_data.R data/train.csv imgs/fig1.jpg ##############

# loading the required libraries
library(tidyverse)
library(gridExtra)

# getting cmd arguments into variables
args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
output_file_fig1 <- args[2]
output_file_fig2 <- args[3]
output_file_fig3 <- args[3]
output_file_fig4 <- args[3]

# comment these lines if running via shell
input_file <- "data/train.csv"
output_file_fig1 <- "imgs/fig1.jpg"
output_file_fig2 <- "imgs/fig2.jpg"
output_file_fig3 <- "imgs/fig3.jpg"
output_file_fig4 <- "imgs/fig4.jpg"
output_file_fig5 <- "imgs/fig5.jpg"

# reding the input
nhl_data <- read_csv(input_file)

# first figure: home or away
nhl_data %>% 
  ggplot(aes(x = home_game.x, y = won.x)) +
  geom_bin2d() +
  labs(x="Canucks Home Game?", y="Did Canucks win?",
       title = "Figure 1: Impact of game location - home or away",
       subtitle = "Lighter blue indicates that this happens more often, darker less") +
  theme_minimal()
ggsave(output_file_fig1)


# function to generate row of plots for all moving averages
generate_plot_row <- function(x_var_start, output_file, title) {
  plot1 <- generate_plot(x_var_start, "previous 1-games")
  plot3 <- generate_plot(str_replace(x_var_start,"1","3"), "previous 3-games")
  plot5 <- generate_plot(str_replace(x_var_start,"1","5"), "previous 5-games")
  plot10 <- generate_plot(str_replace(x_var_start,"1","10"), "previous 10-games")
  g <- arrangeGrob(nrow=1, plot1, plot3, plot5, plot10,top=title)
  ggsave(file=output_file, g, width=200, height = 50, units = "mm")
}

# function to generate a single density plot for a given variable 
generate_plot <- function(x_var, title) {

  plot_data <- subset(nhl_data, select=c("won.x", x_var))
  colnames(plot_data)[1] <- "won"
  colnames(plot_data)[2] <- "x"
  
  x_min = min(plot_data[2])
  x_max = max(plot_data[2])
  
  plot_data %>% 
    ggplot(aes(x = x)) +
      geom_density(bw=0.2, aes(group=won, colour=won), show.legend=F) +
      xlim(x_min, x_max) +
      labs(x="",y="", title=title) +
      theme_minimal()
}

generate_plot_row("won_prev1.diff", output_file_fig2, "Figure 2: Difference of moving average wins ratio between Canucks and opponent \n Note: single feature density histogram, blue line is for games won by Canucks, red is for losses")
generate_plot_row("shots_ratio_prev1.diff", output_file_fig3, "Figure 3: Difference of moving average shots ratio between Canucks and opponent \n Note: single feature density histogram, blue line is for games won by Canucks, red is for losses")
generate_plot_row("goals_ratio_prev1.diff", output_file_fig4, "Figure 4: Difference of moving average goals ratio between Canucks and opponent \n Note: single feature density histogram, blue line is for games won by Canucks, red is for losses")
generate_plot_row("save_ratio_prev1.diff", output_file_fig5, "Figure 5: Difference of moving average save ratio between Canucks and opponent \n Note: single feature density histogram, blue line is for games won by Canucks, red is for losses")
