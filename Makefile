# Makefile
# Objective : This script runs the NHL win/loss prediction analysis from top to bottom
# Team members :
# Aditya Sharma (ashrm21)
# Shayne Andrews (shayne19)


###########################
# Run the whole pipeline
###########################
# The Master step :
# The all command will run the whole analysis including
# - cleaning the data
# - EDA
# - hyperparameter tuning and cross-validation and finding feature importance
# - fitting the final model
# - creating the report for the analysis
all : doc/results_report.md

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

###########################
# Remove all files
###########################
# Removes all the files generated during the analysis
clean :
	rm -f results/model_selection.csv
	rm -f results/dtree
	rm -f results/dtree.pdf
	rm -f results/feature_importance.csv
	rm -f results/final_result.csv
	rm -f results/max_depth.png
	rm -f data/train.csv
	rm -f data/test.csv
	rm -f imgs/fig-1_home-away.jpg
	rm -f imgs/fig-2_shots-diff.jpg
	rm -f doc/results_report.md
	rm -f doc/results_report.html
	rm -f Rplots.pdf
