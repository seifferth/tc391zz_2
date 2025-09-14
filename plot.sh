#!/bin/bash

test -d plots || mkdir plots
cat <<EOF >plots/all_plots.html
<style>
@page {size: 20cm 15cm; margin: 1cm; }
img { width: 100%; margin: 0; }
</style>
EOF

add_figure() {
test -f "plots/$2" || (
    echo "Plotting $3 ..." >&2
    ./utils/scatterplot.py corpus/genre_metadata.tsv "$1" "plots/$2"
)
cat <<EOF >>plots/all_plots.html
<figure>
<img src="$2" />
<caption>$3</caption>
</figure>
EOF
}

# Add figures for the models that appear in the first table of the
# highlighted results section of 'analysis.md' in order to compare them
# to Christof Schöch's visualization of an aggregated model.
add_figure \
    models/schöch/060tp-6000it-0300in.tsv.gz \
    060tp-6000it-0300in.svg \
    "Schöch's LDA (selected)"
add_figure \
    models/schöch/050tp-6000it-0050in.tsv.gz \
    050tp-6000it-0050in.svg \
    "Schöch's LDA (best)"
add_figure \
    models/preproc/lda_id-v04.tsv.gz \
    lda_id-v04.svg \
    "Plain LDA"
add_figure \
    models/preproc/doc2vec_umap-v01.tsv.gz \
    doc2vec_umap-v01.svg \
    "Top2Vec"
add_figure \
    models/preproc/tfidf_umap-v03.tsv.gz \
    tfidf_umap-v03.svg \
    "TF-IDF & UMAP"
# Also add figures for different dimensionalities in order to confirm
# that the Top2Vec and TF-IDF & UMAP figures are not only that appealing
# because they rely on 5-dimensional vector spaces.
add_figure \
    models/preproc/doc2vec_umap-v04.tsv.gz \
    doc2vec_umap-v04.svg \
    "Top2Vec (50 dim.)"
add_figure \
    models/preproc/doc2vec_umap-v05.tsv.gz \
    doc2vec_umap-v05.svg \
    "Top2Vec (100 dim.)"
add_figure \
    models/preproc/tfidf_umap-v04.tsv.gz \
    tfidf_umap-v04.svg \
    "TF-IDF & UMAP (50 dim.)"
add_figure \
    models/preproc/tfidf_umap-v05.tsv.gz \
    tfidf_umap-v05.svg \
    "TF-IDF & UMAP (100 dim.)"
# Finally add the last two figures for models found in the highlighted
# results table.
add_figure \
    models/preproc/lda_umap-v04.tsv.gz \
    lda_umap-v04.svg \
    "LDA & UMAP"
add_figure \
    models/preproc/sbert_umap-v04.tsv.gz \
    sbert_umap-v04.svg \
    "BERTopic (best)"
