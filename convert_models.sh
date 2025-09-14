#!/bin/bash

# First, we convert the models found in projects/2015/gddh/7_model/ into
# the format used by ttm so we can use them as part of our experiments.
test -d models || mkdir models
test -d models/schöch || mkdir models/schöch
ls projects/2015/gddh/7_model/ |
    grep '^topics-in-texts_.*\.csv$' |
    sed 's/^topics-in-texts_//;s/\.csv$//' |
    while read f; do
        test -f "models/schöch/$f.tsv.gz" || (
            echo "Creating models/schöch/$f.tsv.gz" >&2
            ./utils/convert_model.py \
                "projects/2015/gddh/7_model/topics-in-texts_$f.csv" |
                ttm -o "models/schöch/$f.tsv.gz"
        )
    done

# Also reproduce Schöch's aggregation (multiple combinations of the
# aggregation functions used) to see if we can later on reproduce the
# evaluation results he achieved via classification.
test -d models/schöch-agg || mkdir models/schöch-agg
for method in \
    mean \
    median \
    mean_shifted \
    median_shifted \
    median_shift_mean \
    mean_shift_median \
    mean_shifted_std \
    median_shifted_std \
    mean_shift_o_std \
    median_shift_o_std
do
    test -d "models/schöch-agg/$method" || mkdir "models/schöch-agg/$method"
    ls models/schöch/*.tsv.gz | sed 's|^models/schöch/||;s/\.tsv\.gz$//' |
        while read model; do
            test -f "models/schöch-agg/$method/$model.tsv.gz" || (
                echo "Creating models/schöch-agg/$method/$model.tsv.gz" >&2
                ./utils/aggregate_plays.py "$method" \
                    "models/schöch/$model.tsv.gz" \
                    "models/schöch-agg/$method/$model.tsv.gz"
            )
        done
done

# Finally, also convert Christof Schöch's (2017) own clustering of the
# data found in Figure 11 of his article. Since his repo does not seem
# to contain a machine-readable version of the data visualized in this
# figure, I manually copied his results into 'corpus/figure11.tsv'
# based on what is displayed in the image. This allows us to take
# the model he used as a basis for creating this clustering ---
# models/schöch/060tp-6000it-0300in.tsv.gz --- in order to add the
# cluster ids found in corpus/figure11.tsv. (Since I don't add the
# highdim and lowdim columns to the output, I might of course just use
# any of Schöch's models, but still using the correct one feels proper.)
test -d clusters || mkdir clusters
test -d clusters/schöch-agg || mkdir clusters/schöch-agg
test -f clusters/schöch-agg/060tp-6000it-0300in.aggl.tsv.gz || (
    echo "Creating clusters/schöch-agg/060tp-6000it-0300in.aggl.tsv.gz" >&2
    zcat models/schöch/060tp-6000it-0300in.tsv.gz |
        sed 's/^id\t/super_id\tid\t/;s/^\([^§]*\)§/\1\t\1§/' |
        csvsql -I -tu3 - corpus/figure11.tsv --query='
            select stdin.id, figure11.cluster
            from stdin join figure11 on stdin.super_id = figure11.id
        ' | csvcut -C super_id | csvformat -TU3 |
        gzip >clusters/schöch-agg/060tp-6000it-0300in.aggl.tsv.gz
)
