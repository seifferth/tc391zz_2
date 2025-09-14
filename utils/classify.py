#!/usr/bin/env python3
#
# Usage: ./classify.py METADATA MODEL...
#
# The first command line argument (METADATA) must be the path of a
# tsv-file containing the genre metadata for all ids found in any of the
# models. The remaining arguments (MODEL) are topic models that conform
# to the format used by ttm.
#
# Classification results are printed to stdout as a tsv-formatted table.
#
# Code based on 'projects/2015/gddh/code/classify.py' by Christof Schöch.

import sys, json
import pandas
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.linear_model import SGDClassifier
from sklearn.model_selection import cross_val_score

def get_classifier(c: str):
    if c == "SVM":
        return SVC(kernel="linear") # linear|poly|rbf
    elif c == "KNN":
        return KNeighborsClassifier(n_neighbors=5, weights="distance")
    elif c == "TRE":
        return DecisionTreeClassifier()
    elif c == "SGD":
        return SGDClassifier(loss="log_loss", penalty="l2", shuffle=True)
    else:
        raise Exception(f'Unknown classifier {c}')

def classify_withtopics(X, y): 
    """
    Classify items using SVM and evaluate accuracy.
    """
    result = dict()
    cs =  ["SVM", "KNN", "TRE", "SGD"]
    for c in cs:
        accuracy = cross_val_score(get_classifier(c),
                                   X, y, cv=10, scoring="accuracy")
        result[c] = accuracy.mean()
    result["average"] = sum([result[c] for c in cs])/len(cs)
    return result

if __name__ == '__main__':
    metadata = pandas.read_table(sys.argv[1], index_col='id')
    print('model_name', 'SVM', 'KNN', 'TRE', 'SGD', 'average', sep='\t')
    for filename in sys.argv[2:]:
        model = pandas.read_table(filename,
                    usecols=['id', 'lowdim'], index_col='id',
                    dtype={'id': str}, converters={ 'lowdim': json.loads },
                ).join(metadata)
        r = classify_withtopics(model.lowdim.tolist(), model.genre.tolist())
        print('\t'.join([filename]+['{:01.3f}'.format(v) for v in
              [r['SVM'], r['KNN'], r['TRE'], r['SGD'], r['average']]]))
