#!/usr/bin/env python3
#
# Usage: ./aggregate_plays.py METHOD INPUT-MODEL OUTPUT-MODEL
#
# METHODS
#     mean                  Aggregate the embeddings of all segments of a
#                           given play by mean pooling
#     median                Same, but use median pooling instead
#     mean_shifted          Use mean pooling but also shift each resulting
#                           vector by subtracting its own mean (I have no idea
#                           why this might be useful, but apparently Christof
#                           Schöch applied this operation)
#     median_shifted        Same as mean_shifted but using median instead for
#                           both operations
#     median_shift_mean     Use median to aggregate but mean to shift the row
#                           (this is even more surprising than mean_shifted,
#                           but the current commenting of Schöch's code will
#                           do just that)
#     mean_shift_median     For completeness' sake, using mean pooling to
#                           aggregate segments but median to shift the
#                           resulting rows
#     mean_shifted_std      Same as mean_shifted, but also divide each vector
#                           by the standard deviation of its values (Christof
#                           Schöch apparently used this form of aggregation
#                           for creating the PCA-based visualization)
#     median_shifted_std    Like mean_shifted_std but using median instead of
#                           mean for both aggregation and shifting
#     mean_shift_o_std      Same as mean_shift_median, but also divide each
#                           vector by the standard deviation of its values
#     median_shift_o_std    Same as median_shift_mean, but also divide each
#                           vector by the standard deviation of its values
#
# Code based on 'projects/2015/gddh/code/classify.py' by Christof Schöch.

import sys, json
import pandas, numpy

def mean(x):
    return numpy.mean(x, axis=0)
def median(x):
    return numpy.median(x, axis=0)
def mean_shifted(x):
    x = numpy.mean(x, axis=0)
    return x - numpy.mean(x, axis=0)
def median_shifted(x):
    x = numpy.median(x, axis=0)
    return x - numpy.median(x, axis=0)
def median_shift_mean(x):
    x = numpy.median(x, axis=0)
    return x - numpy.mean(x, axis=0)
def mean_shift_median(x):
    x = numpy.mean(x, axis=0)
    return x - numpy.median(x, axis=0)
def mean_shifted_std(x):
    x = numpy.mean(x, axis=0)
    return (x - numpy.mean(x, axis=0)) / numpy.std(x, axis=0)
def median_shifted_std(x):
    x = numpy.median(x, axis=0)
    return (x - numpy.median(x, axis=0)) / numpy.std(x, axis=0)
def mean_shift_o_std(x):
    x = numpy.mean(x, axis=0)
    return (x - numpy.median(x, axis=0)) / numpy.std(x, axis=0)
def median_shift_o_std(x):
    x = numpy.median(x, axis=0)
    return (x - numpy.mean(x, axis=0)) / numpy.std(x, axis=0)

if __name__ == '__main__':
    if sys.argv[1] == 'mean':                 pooling_func = mean
    elif sys.argv[1] == 'median':             pooling_func = median
    elif sys.argv[1] == 'mean_shifted':       pooling_func = mean_shifted
    elif sys.argv[1] == 'median_shifted':     pooling_func = median_shifted
    elif sys.argv[1] == 'median_shift_mean':  pooling_func = median_shift_mean
    elif sys.argv[1] == 'mean_shift_median':  pooling_func = mean_shift_median
    elif sys.argv[1] == 'mean_shifted_std':   pooling_func = mean_shifted_std
    elif sys.argv[1] == 'median_shifted_std': pooling_func = median_shifted_std
    elif sys.argv[1] == 'mean_shift_o_std':   pooling_func = mean_shift_o_std
    elif sys.argv[1] == 'median_shift_o_std': pooling_func = median_shift_o_std
    else:           raise Exception(f'Unknown pooling method: {sys.argv[1]}')
    model = pandas.read_table(sys.argv[2],
                usecols=['id', 'lowdim'], index_col='id',
                dtype={'id': str}, converters={ 'lowdim': json.loads },
            )
    model['work_id'] = model.index.map(lambda x: x.split('§')[0])
    model = model.groupby('work_id').agg({
        'lowdim': lambda x: pooling_func(x.tolist()).tolist()
    })
    model.to_csv(sys.argv[3], sep='\t', index_label='id')
