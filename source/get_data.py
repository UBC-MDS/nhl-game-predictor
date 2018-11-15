# importing the required library
# !conda install pandas
# !pip install pandas
import pandas as pd

# reading the data file from the data folder
nhl_data = pd.read_csv("../data/game_teams_stats.csv")

# subsetting the data for the Vancouver team (team_id = 23)
nhl_data_van = nhl_data[nhl_data['team_id'] == 23]

# looking at a snippet of the data
nhl_data_van.head(10)
