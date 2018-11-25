#!/usr/bin/env python3
# building_model.py
# Shayne, Aditya, Nov 2018
#
# This script finds the best parameters for the models
# using decison trees and random forest algorithm and
# exports the features and model selection info

# Dependencies: argparse, pandas, numpy, graphviz, sklearn, matplotlib
#
# Usage: python3 source/finding_best_model.py data/train.csv data/test.csv results/

# importing the required libraries
import pandas as pd
import numpy as np
import argparse
import matplotlib.pyplot as plt
from sklearn import tree
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score

from sklearn.tree import export_graphviz
# !pip install graphviz
import graphviz

np.random.seed(1234)

# read in command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('training_data')
parser.add_argument('test_data')
parser.add_argument('output_folder')
args = parser.parse_args()

# putting values from arguments into variables
train_data = args.training_data
test_data = args.test_data
output_folder = args.output_folder

# reading required files
train = pd.read_csv(train_data)
test = pd.read_csv(test_data)

def get_features():
    ''' function to get the relevant features to put into the model
    '''
    features = [f for f in train.columns.values if f not in 'won.x']
    return features

def create_train_test_model(features):
    '''
    function to extract the data based on the selected features
    '''
    Xtrain = train.loc[:, features]
    ytrain = train['won.x']

    Xtest = test.loc[:, features]
    ytest = test['won.x']

    return Xtrain, ytrain, Xtest, ytest


def get_feature_importance(Xtrain, ytrain, features):
    '''
    function to build a decision tree with all
    features to see feature importance
    '''
    model = tree.DecisionTreeClassifier(random_state = 1234)
    model.fit(Xtrain, ytrain)
    model.score(Xtrain, ytrain)

    imp = model.feature_importances_
    features = np.array(features)

    importance_map = zip(features, imp)
    sorted_features = sorted(importance_map, key=lambda x: x[1])

    top_n_features = [i[0] for i in sorted_features[:20]]
    return top_n_features, sorted_features


def tuning_max_depth_dt(depth, Xtrain, ytrain):
    '''
    Function to tune max_depth for a decision tree
    '''
    # building a decision tree classifier
    print("Current Depth: {0}".format(depth))
    model = tree.DecisionTreeClassifier(max_depth = depth, random_state = 1234)
    model.fit(Xtrain, ytrain)

    curr_score = cross_val_score(model, Xtrain, ytrain, cv = 10)
    return np.mean(curr_score)


def tuning_max_depth_rf(depth, Xtrain, ytrain):
    '''
    Function to tune max_depth for a decision tree
    '''
    # building a random forest classifier
    print("Current Depth: {0}".format(depth))
    model = RandomForestClassifier(max_depth = depth, random_state = 1234,
                                    n_estimators = 300, verbose = 1)
    model.fit(Xtrain, ytrain)

    curr_score = cross_val_score(model, Xtrain, ytrain, cv = 10)
    return np.mean(curr_score)

def export_cross_valid_plot(depth_vals, validation_dt):
    '''
    plotting and saving the variation of accuracy with max_depth
    '''
    plt.plot(depth_vals, validation_dt)
    plt.xlabel("max depth - hyperparameter")
    plt.ylabel("Accuracy")
    plt.title("Validation accuracy with max depth in a decison tree")
    plt.savefig(output_folder + "max_depth.png")


def export_feature_importance(sorted_features):
    '''
    writing features with their importances in a data frameand exporting it
    '''
    feature_importance = pd.DataFrame(sorted_features, columns=['features', 'importance'])
    feature_importance.to_csv(output_folder + "feature_importance.csv")

def main():

    features = get_features()

    # extracting the data based on the selected features
    Xtrain, ytrain, Xtest, ytest = create_train_test_model(features)

    top_n_features, sorted_features = get_feature_importance(Xtrain, ytrain, features)
    Xtrain = train.loc[:, top_n_features]
    Xtest = test.loc[:, top_n_features]

    # using cross valudation to tune max_depth in a decision tree
    validation_dt = np.zeros(8)
    validation_rf = np.zeros(8)

    # trying different values of the hyperparameter max_depth
    depth_vals = np.arange(1, 9)
    for depth in depth_vals:
        validation_dt[depth - 1] = tuning_max_depth_dt(depth, Xtrain, ytrain)

    depth_vals = np.arange(1, 9)
    for depth in depth_vals:
        validation_rf[depth - 1] = tuning_max_depth_rf(depth, Xtrain, ytrain)

    # scoring the models on a large depth
    model = tree.DecisionTreeClassifier(max_depth = 25, random_state = 1234)
    score_depth_25_dt = tuning_max_depth_dt(25, Xtrain, ytrain)
    score_depth_25_rf = tuning_max_depth_rf(25, Xtrain, ytrain)

    print("Cross validation score with depth 25 on Decision Tree: {0}".format(score_depth_25_dt))
    print("Cross validation score with depth 25 on Random Forest: {0}".format(score_depth_25_rf))

    # exporting model selection table
    select_model = pd.DataFrame({'depth' : np.arange(1,9), 'scores_dt' : validation_dt, 'scores_rf' : validation_rf})
    select_model.to_csv(output_folder + "model_selection.csv")

    # exporting plot for CV and feature importance table
    export_cross_valid_plot(depth_vals, validation_dt)
    export_feature_importance(sorted_features)

# call main function
if __name__ == "__main__":
    main()
