#!/usr/bin/env python3
#
# Usage: ./scatterplot.py METADATA MODEL SVG-IMAGE
#
# Code based on 'projects/2015/gddh/code/cluster.py' by Christof Schöch.

import sys, json
import pandas
import numpy
from sklearn.decomposition import PCA
import pygal

tp_style = pygal.style.Style(
    background='white',
    plot_background='white',
    font_family = "FreeSans",
    title_font_size = 16,
    legend_font_size = 16,
    label_font_size = 12,
    value_font_size = 8,
    colors=["darkred", "darkgreen", "navy"]
    )

def apply_pca_t(topicdata): 
    # PCA itself
    pca = PCA()
    pca.fit(topicdata)
    variance = pca.explained_variance_ratio_
    transformed = pca.transform(topicdata)
    allpcloadings = pca.components_
    # Get cumulated variance for the PCs.
    cumulated_variance = 0
    dimensions_count = 0
    for item in variance: 
        cumulated_variance = item+cumulated_variance
        dimensions_count +=1
    return transformed, variance, allpcloadings

def make_2dscatterplot_t(transformed, variance, labels):
    xtitle = "PC1 (" + '{:01.0f}'.format(variance[0]*100) + "%)"
    ytitle = "PC2 (" + '{:01.0f}'.format(variance[1]*100) + "%)"
    plot = pygal.XY(style=tp_style,
                    stroke=False,
                    legend_at_bottom=True,
                    legend_at_bottom_columns = 3,
                    x_title = xtitle,
                    y_title = ytitle,
                    )
    d = dict()
    for i in range(len(transformed)):
        if labels[i] not in d:
            d[labels[i]] = list()
        d[labels[i]].append({ "value": (transformed[i][0], transformed[i][1]) })
    #for k, v in d.items():
    #    plot.add(k, v)
    # The following implementation is far less generic than the one above;
    # but at the same time it is closer to Schöch (2017)
    for k in ['comedies', 'tragicomedies', 'tragedies']:
        plot.add(k, d[k], dots_size=1)
    return plot

if __name__ == '__main__':
    metadata = pandas.read_table(sys.argv[1], index_col='id')
    model = pandas.read_table(sys.argv[2],
                usecols=['id', 'lowdim'], index_col='id',
                dtype={'id': str}, converters={ 'lowdim': json.loads },
            ).join(metadata)
    transformed, variance, _loadings = apply_pca_t(model.lowdim.tolist())
    plot = make_2dscatterplot_t(transformed, variance, model.genre.tolist())
    plot.render_to_file(sys.argv[3])
