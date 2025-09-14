#!/usr/bin/env python3
#
# Usage: ./genre_purity.py METADATA MODEL...
#
# Just like in classify.py, the first command line argument (METADATA)
# is the path of a tsv-file containing the genre metadata. The remaining
# arguments (MODEL) are topic models that conform to the format used
# by ttm.
#
# Results are printed to stdout as a tsv-formatted table.

import sys, json
import pandas, numpy

def genre_purity(model):
    # Define the 'genre purity' of a cluster as the percentage of members
    # that belong to the most frequent genre. In case there are two
    # equally prominent genres, the result of the calculation is the
    # same for both genres, so we do not even need to special-case this.
    agg = model.groupby(['cluster', 'genre']) \
               .agg(lambda x: len(x)) \
               .groupby('cluster') \
               .agg([
                    ('purity', lambda x: max(x)/sum(x)),
                    ('members', lambda x: sum(x)),
                ])
    # For aggregating the purity across clusters, we want to use a
    # weighted average that is sensitive to the clusters' size. If we do
    # not do this, clusterings that produce a few big clusters and many
    # small ones --- where the small ones may be as small as a single
    # item, which automatically causes their purity to increase to 100 %
    # --- will be assigned unreasonably high levels of 'genre purity'.
    return numpy.average(agg.purity, weights=agg.members), \
           json.dumps({c: agg.purity[c] for c in agg.index})

if __name__ == '__main__':
    metadata = pandas.read_table(sys.argv[1], index_col='id')
    print('model_name', 'genre_purity', 'genre_purity_by_cluster', sep='\t')
    for filename in sys.argv[2:]:
        model = pandas.read_table(filename,
                    usecols=['id', 'cluster'], index_col='id',
                    dtype={'id': str, 'cluster': str},
                ).join(metadata)
        print(filename, *genre_purity(model), sep='\t')
