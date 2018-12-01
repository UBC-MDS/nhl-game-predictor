
# Aditya Shayne
all : doc/results_report.md

data/train.csv data/test.csv : source/cleaning_nhl_data.R data/game_teams_stats.csv data/team_id.txt
	Rscript source/cleaning_nhl_data.R data/game_teams_stats.csv data/train.csv data/test.csv data/team_id.txt

imgs/fig-1_home-away.jpg : source/exploring_nhl_data.R data/train.csv
	Rscript source/exploring_nhl_data.R data/train.csv imgs/fig-1_home-away.jpg home_game.x "Canucks Home Game?" TRUE "Figure 1: Impact of game location - home or away"

imgs/fig-2_shots-diff.jpg : source/exploring_nhl_data.R data/train.csv
	Rscript source/exploring_nhl_data.R data/train.csv imgs/fig-2_shots-diff.jpg shots_ratio_prev1.diff "" FALSE "Figure 2: Difference of moving average shots ratio between Canucks and opponent"

results/model_selection.csv results/feature_importance.csv results/max_depth.png : source/finding_best_model.py data/train.csv data/test.csv
	python3 source/finding_best_model.py data/train.csv data/test.csv results/

results/final_result.csv results/dtree results/dtree.pdf : source/building_model.py results/model_selection.csv data/train.csv data/test.csv results/feature_importance.csv
	python3 source/building_model.py results/model_selection.csv data/train.csv data/test.csv results/ results/feature_importance.csv

doc/results_report.md : doc/results_report.Rmd data/train.csv data/test.csv imgs/fig-1_home-away.jpg imgs/fig-2_shots-diff.jpg results/model_selection.csv results/feature_importance.csv results/max_depth.png results/final_result.csv results/dtree results/dtree.pdf
	Rscript -e "rmarkdown::render('doc/results_report.Rmd')"

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
