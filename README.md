# Predicting win/loss for NHL games using Supervised Learning

<center><img src = "http://media.contentapi.ea.com/content/www-easports/en_US/nhl/news/2018/nhl-19-features-real-motion-tech-skating/_jcr_content/imageShare.img.jpg"></center>

### Contributors

- [Shayne Andrews](https://github.com/shayne-andrews)
- [Aditya Sharma](https://github.com/adityashrm21/)

## Introduction
NHL hockey games are notoriously difficult to predict. There is [common acceptance](https://www.nhlnumbers.com/2013/08/01/machine-learning-and-hockey-is-there-a-theoretical-limit-on-predictions) among hockey analytics enthusiasts that it is not possible to do better than 62% accuracy (i.e. 38% is due to luck). Interestingly, the NHL has recently [announced a partnership](https://www.nhl.com/news/nhl-mgm-resorts-sports-betting-partnership/c-301392322) with MGM Resorts to enable sports betting.

> Could we do better than 62% accuracy using supervised machine learning?

At this stage the model is focused on the smaller subquestion of predicting games for **only the Vancouver Canucks**.

## Model Description

Here is **[the report](https://github.com/UBC-MDS/DSCI-522_nhl-game-predictor/blob/master/doc/results_report.md)** from our initial model build which uses machine learning decision trees and random forests.

The main variables we use in this model are as follows:  
- Did the team of interest win the game? (won column, TRUE/FALSE)  
- Home or Away game? (HoA column, home/away)  
- Who is the opponent? (team_id column, 1-31)  
- What proportion of *goals* were scored by the team of interest? (calculated using goals column for both teams, 0-1)  
- What proportion of *shots* were made by the team of interest? (calculated using shots column for both teams, 0-1)  
- What proportion of *shots* were *saved* by the team of interest? (calculated using goals and shots columns, 0-1)  

## Usage

#### Using Docker

1. Install [Docker](https://www.docker.com/get-started).
2. Download and clone this repository.
3. Run the following code in terminal to download the Docker image:
```
docker pull adityashrm21/dsci-522_nhl-game-predictor
```

4. Use the command line to navigate to the root of this repo.
5. Type the following code into terminal to run the analysis (filling in PATH_ON_YOUR_COMPUTER with the absolute path to the root of this project on your computer):

```
docker run --rm -it -e PASSWORD=nhlprediction -v <PATH_ON_YOUR_COMPUTER>:/home/nhl/nhl-game-predictor adityashrm21/dsci-522_nhl-game-predictor:latest make -C "/home/nhl/nhl-game-predictor" all
```

6. If you would like a fresh start, type the following:

```
docker run --rm -it -e PASSWORD=nhlprediction -v <PATH_ON_YOUR_COMPUTER>:/home/nhl/nhl-game-predictor adityashrm21/dsci-522_nhl-game-predictor:latest make -C "/home/nhl/nhl-game-predictor" clean
```

#### Using make command

Use [Makefile](https://github.com/UBC-MDS/DSCI-522_nhl-game-predictor/blob/master/Makefile) to run the whole pipeline:

  - Clone this repository and then navigate to the root directory and run the following commands:

```bash
make clean # to clean up existing files and pre-existing results/images
make all # to run all the scripts and create fresh results and output
```
The description of the files and the make commands is provided below as well as in the [Makefile](https://github.com/UBC-MDS/DSCI-522_nhl-game-predictor/blob/master/Makefile).

```bash
#################################
# Steps involved in the analysis
#################################

# Step 1: Cleans the data and creates train and test datasets
data/train.csv data/test.csv : source/cleaning_nhl_data.R data/game_teams_stats.csv data/team_id.txt
	Rscript source/cleaning_nhl_data.R data/game_teams_stats.csv data/train.csv data/test.csv data/team_id.txt

# Step 2: EDA along with creating relavent graph using data generated frmo step 1
imgs/fig-1_home-away.jpg : source/exploring_nhl_data.R data/train.csv
	Rscript source/exploring_nhl_data.R data/train.csv imgs/fig-1_home-away.jpg home_game.x "Canucks Home Game?" TRUE "Figure 1: Impact of game location - home or away"

# Step 3: EDA along with creating relavent graph using data generated frmo step 1
imgs/fig-2_shots-diff.jpg : source/exploring_nhl_data.R data/train.csv
	Rscript source/exploring_nhl_data.R data/train.csv imgs/fig-2_shots-diff.jpg shots_ratio_prev1.diff "" FALSE "Figure 2: Difference of moving average shots ratio between Canucks and opponent"

# Step 4: Uses data created from step 1 to generate model selection table and feature importances using cross validation
results/model_selection.csv results/feature_importance.csv results/max_depth.png : source/finding_best_model.py data/train.csv data/test.csv
	python3 source/finding_best_model.py data/train.csv data/test.csv results/

# Step 5: Uses the output from step 4 to build the final model using top 12 features and generate the final results
results/final_result.csv results/dtree results/dtree.pdf : source/building_model.py results/model_selection.csv data/train.csv data/test.csv results/feature_importance.csv
	python3 source/building_model.py results/model_selection.csv data/train.csv data/test.csv results/ results/feature_importance.csv

# Step 6: creating the markdown report file using the output from all the above steps
doc/results_report.md : doc/results_report.Rmd data/train.csv data/test.csv imgs/fig-1_home-away.jpg imgs/fig-2_shots-diff.jpg results/model_selection.csv results/feature_importance.csv results/max_depth.png results/final_result.csv results/dtree results/dtree.pdf
	Rscript -e "rmarkdown::render('doc/results_report.Rmd')"
```
#### Running scripts manually

- Clone this repo, and using the command line, navigate to the root of this project.

- Run the following commands:

```
Rscript source/cleaning_nhl_data.R data/game_teams_stats.csv data/train.csv data/test.csv data/team_id.txt
Rscript source/exploring_nhl_data.R data/train.csv imgs/fig-1_home-away.jpg home_game.x "Canucks Home Game?" TRUE "Figure 1: Impact of game location - home or away"
Rscript source/exploring_nhl_data.R data/train.csv imgs/fig-2_shots-diff.jpg shots_ratio_prev1.diff "" FALSE "Figure 2: Difference of moving average shots ratio between Canucks and opponent"
python3 source/finding_best_model.py data/train.csv data/test.csv results/
python3 source/building_model.py results/model_selection.csv data/train.csv data/test.csv results/ results/feature_importance.csv
Rscript -e "rmarkdown::render('doc/results_report.Rmd')"
```

## Makefile dependency graph

<br>
<center><img src = "https://github.com/UBC-MDS/DSCI-522_nhl-game-predictor/blob/master/imgs/Makefile.png?raw=True"></center>
<br>

## Dependencies
- R & R libraries:
    - `tidyverse`
    - `rmarkdown`
    - `knitr`
    - `here`
    - `zoo`
    - `gridExtra`
- Python & Python libraries:
    - `matplotlib`
    - `numpy`
    - `pandas`
    - `sklearn`
    - `argparse`
    - `graphviz`
