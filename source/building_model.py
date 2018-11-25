#!/usr/bin/env python3
# building_model.py
# Shayne, Aditya, Nov 2018
#
# This script builds the final model on the data using
# the exported information from finding_best_model.py

# Dependencies: argparse, pandas, numpy, graphviz, sklearn, matplotlib
#
# Usage: python3 source/building_model.py results/model_selection.csv data/train.csv data/test.csv results/ results/feature_importance.csv

# importing the required libraries
import pandas as pd
import numpy as np
import argparse
import graphviz
import matplotlib.pyplot as plt
from sklearn import tree
from sklearn.ensemble import RandomForestClassifier

np.random.seed(1234)

# read in command line arguments
parser = argparse.ArgumentParser()

parser.add_argument('model_select')
parser.add_argument('training_data')
parser.add_argument('test_data')
parser.add_argument('output_folder')
parser.add_argument('imp_features')
args = parser.parse_args()

# putting values from arguments into variables
model_select = args.model_select
train_data = args.training_data
test_data = args.test_data
output_folder = args.output_folder
features = args.imp_features

# reading requored files
select_model = pd.read_csv(model_select)
feature_importance = pd.read_csv(features)
train = pd.read_csv(train_data)
test = pd.read_csv(test_data)

# extracting the features to be used in the final model
features = feature_importance.sort_values(by = ['importance'], ascending = False)
top_n_features = [i for i in features['features'][:12]]

# subsetting the train and test data with relevant features
Xtrain = train.loc[:, top_n_features]
Xtest = test.loc[:, top_n_features]
ytrain = train['won.x']
ytest = test['won.x']


def build_final_model_dt(best_depth):
    '''
    function to build final model using a decision tree
    '''
    # fitting the final model using a random forest with n_estimators = 500 and max_depth = best depth
    final_model = tree.DecisionTreeClassifier(max_depth = best_depth, random_state = 1234)
    final_model.fit(Xtrain, ytrain)

    # predicting on the test dataset
    predictions = final_model.predict(Xtest)
    accuracy = final_model.score(Xtest, ytest)
    #accuracy_dt = final_model_dt.score(Xtest, ytest)
    graph = save_and_show_decision_tree(final_model, feature_names = top_n_features,
                                        class_names=['Loss', 'Win'],
                                        save_file_prefix = output_folder + 'dtree')
    #print("Final accuracy obtained with DT on the test dataset is: {0}".format(accuracy))
    return accuracy


def build_final_model_rf(best_depth):
    '''
    function to build final model using a randomc forest
    '''
    # fitting the final model using a random forest with n_estimators = 500 and max_depth = best depth
    final_model = RandomForestClassifier(n_estimators = 500, max_depth = best_depth, random_state = 1234)
    final_model.fit(Xtrain, ytrain)

    # predicting on the test dataset
    predictions = final_model.predict(Xtest)
    accuracy = final_model.score(Xtest, ytest)
    #accuracy_dt = final_model_dt.score(Xtest, ytest)
    print("Final accuracy obtained with RF on the test dataset is: {0}".format(accuracy))
    return accuracy

# function to save decision tree created and store it in results directory
def save_and_show_decision_tree(model,
                                feature_names,
                                class_names,
                                save_file_prefix, **kwargs):
    """
    Saves the decision tree model as a pdf
    """
    dot_data = tree.export_graphviz(model, out_file=None,
                             feature_names=feature_names,
                             class_names=class_names,
                             filled=True, rounded=True,
                             special_characters=True, **kwargs)

    graph = graphviz.Source(dot_data)
    graph.render(save_file_prefix)
    return graph


def export_final_result(best_depth_rf, best_rf_accuracy):
    '''
    function to export final table of summary
    '''
    result = pd.DataFrame({'depth' : [best_depth_rf],
                            'algorithm' : ['RandomForest'],
                            'accuracy' : [best_rf_accuracy]})
    result.to_csv(output_folder + 'final_result.csv')

def main():

    best_depth_dt = np.argmax(select_model['scores_dt']) + 1
    #print("The best depth for decision tree is: {0}".format(best_depth_dt))
    best_depth_rf = np.argmax(select_model['scores_rf']) + 1
    print("The best depth for random forest is: {0}".format(best_depth_rf))

    # building final models
    best_dt_accuracy = build_final_model_dt(best_depth_dt)
    best_rf_accuracy = build_final_model_rf(best_depth_rf)

    # exporting final model using random forest
    export_final_result(best_depth_rf, best_rf_accuracy)


# call main function
if __name__ == "__main__":
    main()
