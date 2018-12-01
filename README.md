# Predicting win/loss for NHL games using Supervised Learning

## Introduction
NHL hockey games are notoriously difficult to predict. There is [common acceptance](https://www.nhlnumbers.com/2013/08/01/machine-learning-and-hockey-is-there-a-theoretical-limit-on-predictions) among hockey analytics enthusiasts that it is not possible to do better than 62% accuracy (i.e. 38% is due to luck). Interestingly, the NHL has recently [announced a partnership](https://www.nhl.com/news/nhl-mgm-resorts-sports-betting-partnership/c-301392322) with MGM Resorts to enable sports betting.

> Could we do better than 62% accuracy using supervised machine learning?

At this stage the model is focused on the smaller subquestion of predicting games for **only the Vancouver Canucks**.

## Initial Model

Here is **[the report](https://github.com/UBC-MDS/DSCI-522_nhl-game-predictor/blob/master/doc/results_report.md)** from our initial model build which uses machine learning decision trees and random forests.

The main variables we use in this model are as follows:  
- Did the team of interest win the game? (won column, TRUE/FALSE)  
- Home or Away game? (HoA column, home/away)  
- Who is the opponent? (team_id column, 1-31)  
- What proportion of *goals* were scored by the team of interest? (calculated using goals column for both teams, 0-1)  
- What proportion of *shots* were made by the team of interest? (calculated using shots column for both teams, 0-1)  
- What proportion of *shots* were *saved* by the team of interest? (calculated using goals and shots columns, 0-1)  

## Usage

1. Clone this repo, and using the command line, navigate to the root of this project.

2. Run the following commands:

```
Rscript source/cleaning_nhl_data.R data/game_teams_stats.csv data/train.csv data/test.csv data/team_id.txt
Rscript source/exploring_nhl_data.R data/train.csv imgs/fig-1_home-away.jpg home_game.x "Canucks Home Game?" TRUE "Figure 1: Impact of game location - home or away"
Rscript source/exploring_nhl_data.R data/train.csv imgs/fig-2_shots-diff.jpg shots_ratio_prev1.diff "" FALSE "Figure 2: Difference of moving average shots ratio between Canucks and opponent"
python3 source/finding_best_model.py data/train.csv data/test.csv results/
python3 source/building_model.py results/model_selection.csv data/train.csv data/test.csv results/ results/feature_importance.csv
Rscript -e "rmarkdown::render('doc/results_report.Rmd')"
```

## Dependencies
- R & R libraries:
    - `tidyverse`
    - `rmarkdown`
    - `knitr`
    - `here`
- Python & Python libraries:
    - `matplotlib`
    - `numpy`
    - `pandas`
    - `sklearn`
    - `argparse`
    - `graphviz`
