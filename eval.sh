#!/bin/bash

test -d metrics || mkdir metrics

# Calculate psq_distance for all models in models/ using a number of
# different distance metrics
for metric in euclidean cosine cityblock; do
    # Evaluate models in models/schöch/ all at once
    test -f "models/schöch/metrics.$metric.psq_distance" || (
        echo "Evaluating models/schöch/* using $metric distance" >&2
        ttm eval --format=tsv --skip-separation-metrics \
            --psq-pairs=corpus/psq_pairs.tsv \
            --psq-distance-metric="$metric" models/schöch/*.tsv.gz |
            cut -f1,5-7,12-13 >models/schöch/"metrics.$metric.psq_distance"
    )
    # Evaluate any new models in models/preproc/ and models/raw/
    ls models/preproc/*.tsv.gz models/raw/*.tsv.gz | sed 's/\.tsv\.gz$//' |
        while read f; do
            test -f "$f.$metric.psq_distance" || (
                echo "Evaluating $f.tsv.gz using $metric distance" >&2
                ttm eval --format=tsv --skip-separation-metrics \
                    --psq-pairs=corpus/psq_pairs.tsv \
                    --psq-distance-metric="$metric" "$f.tsv.gz" |
                    cut -f1,5-7,12-13 >"$f.$metric.psq_distance"
            )
        done
    # Combine the results for all corpora and models
    echo "Creating combined results file metrics/$metric.psq_distance.tsv" >&2
    csvstack -tu3 models/*/*."$metric.psq_distance" |
        csvformat -TU3 >"metrics/$metric.psq_distance.tsv"
done

# Reproduce Schöch's classification task using ./utils/classify.py
#
# Classify models in models/schöch/ all at once
for i in 01 02 03; do
    test -f "models/schöch/metrics.run_$i.classify" || (
        echo "Running ./utils/classify.py on" \
             "models/schöch/*.tsv.gz (run $i)" >&2
        ./utils/classify.py corpus/genre_metadata.tsv \
            models/schöch/*.tsv.gz >"models/schöch/metrics.run_$i.classify"
    )
done
# Let's see if we can reproduce Schöch's results if we run classification
# on the aggregated models
for d in $(find models/schöch-agg/* -type d); do
    for i in 01 02 03; do
        test -f "$d.run_$i.classify" || (
            echo "Running ./utils/classify.py on $d/*.tsv.gz (run $i)" >&2
            ./utils/classify.py corpus/genre_metadata.tsv \
                "$d"/*.tsv.gz >"$d.run_$i.classify"
        )
    done
done
# Classify any new models in models/preproc/
ls models/preproc/*.tsv.gz | sed 's/\.tsv\.gz$//' |
    while read f; do
        for i in 01 02 03; do
            test -f "$f.run_$i.classify" || (
                echo "Running ./utils/classify.py on" \
                     "$f.tsv.gz (run $i)" >&2
                ./utils/classify.py corpus/genre_metadata.tsv \
                    "$f.tsv.gz" >"$f.run_$i.classify"
            )
        done
    done
# Combine the classification results for all corpora and models
echo "Creating combined results file metrics/classify.tsv" >&2
for i in 01 02 03; do
    csvstack -t -u3 models/*/*.run_$i.classify |
        csvformat -T -U3 >"metrics/run_$i.classify.tmp"
done
test -f metrics/schöch_2017.classify.tsv || (
    csvsql --no-inference \
        projects/2015/gddh/8_diagnostics/classify_topic-results.csv \
        projects/2015/gddh/8_diagnostics/classify_word-results.csv \
        --query '
            select
                printf("models/schöch/%stp-6000it-%sin.tsv.gz",
                       substr(a, 1, 3), substr(a, 5, 4)) as model_name,
                SVM, KNN, TRE, SGD, average
            from [classify_topic-results]
            union select
                printf("MFW_%s", a) as model_name,
                SVM, KNN, TRE, SGD,
                round((SVM+KNN+TRE+SGD)/4, 5) as average
            from [classify_word-results]
        ' | csvformat -T -U3 >metrics/schöch_2017.classify.tsv
)
csvstack -t -u3 -n run -g 01,02,03,schöch_2017 \
    metrics/run_01.classify.tmp \
    metrics/run_02.classify.tmp \
    metrics/run_03.classify.tmp \
    metrics/schöch_2017.classify.tsv |
    csvformat -T -U3 >"metrics/classify.tsv" &&
    rm metrics/run_0[123].classify.tmp

# Calculate psq_score for all models in clusters/
ls clusters/*/*.tsv.gz |
    grep -v '^clusters/schöch-agg/' |
    sed 's/\.tsv\.gz$//' |
        while read f; do
            test -f "$f.psq_score" || (
                echo "Evaluating $f.tsv.gz using the psq_score metric" >&2
                ttm eval --format=tsv --skip-separation-metrics \
                    --skip-psq-distance --psq-pairs=corpus/psq_pairs.tsv \
                    "$f.tsv.gz" | cut -f1-4,14-15 >"$f.psq_score"
            )
        done
# Calculate psq_score separately for the model in clusters/schöch-agg/,
# since for the case of models that were first aggregated and later
# re-expanded it makes little sense to calculate psq_score
test -f clusters/schöch-agg/060tp-6000it-0300in.aggl.psq_score || (
    ttm eval --format=tsv --skip-separation-metrics --skip-psq-distance \
        clusters/schöch-agg/060tp-6000it-0300in.aggl.tsv.gz |
        cut -f1-4,14-15 |
        cat >clusters/schöch-agg/060tp-6000it-0300in.aggl.psq_score
)
# Calculate genre purity for all models in clusters/
ls clusters/*/*.tsv.gz | sed 's/\.tsv\.gz$//' |
    while read f; do
        test -f "$f.genre_purity" || (
            echo "Evaluating $f.tsv.gz using the genre_purity metric" >&2
            ./utils/genre_purity.py corpus/genre_metadata.tsv "$f.tsv.gz" \
                >"$f.genre_purity"
        )
    done

# Combine the results for all clustered models in metrics.psq_score
if grep -q % clusters/*/*.psq_score clusters/*/*.genre_purity; then
    echo "Unexpected error: % round in a psq_score or genre_purity file" >&2
    exit 1
fi
echo "Creating combined results file metrics/psq_score.tsv" >&2
csvgrep -tu3 metrics/euclidean.psq_distance.tsv \
    -c model_name -r '^(models/preproc/|models/schöch/)' |
    sed 's|^model_name,|base_model_key,base_model,|' |
    sed 's|^\(models/\(preproc/[^\.]*\)\.tsv\.gz\),|\2,\1,|' |
    sed 's|^\(models/\(schöch/[^\.]*\)\.tsv\.gz\),|\2,\1,|' |
    csvcut -c base_model_key,base_model,highdim_size,lowdim_size |
    csvformat -TU3 -Q% >metrics/base_model_metadata.tmp
csvstack -tu3 clusters/*/*.psq_score |
    sed 's|^model_name,|base_model_key,model_name,|' |
    sed 's|^\(clusters/\([^/]*/[^\.]*\)\.[^\.]*\.tsv\.gz\),|\2,\1,|' |
    sed 's|^schöch-agg/|schöch/|' |
    csvformat -TU3 -Q% >metrics/psq_score.tmp
csvstack -tu3 clusters/*/*.genre_purity |
    csvformat -TU3 -Q% >metrics/genre_purity.tmp
csvsql -I metrics/{base_model_metadata,psq_score,genre_purity}.tmp --query='
        select
                genre_purity.model_name as model_name,
                psq_score.psq_score, psq_score_zoom, psq_count,
                    clusters, cluster_distribution,
                genre_purity.genre_purity, genre_purity_by_cluster,
                base_model_metadata.base_model, highdim_size, lowdim_size
        from genre_purity full join psq_score on
                genre_purity.model_name = psq_score.model_name
        left join base_model_metadata on
                psq_score.base_model_key = base_model_metadata.base_model_key
    ' | csvformat -TU3 -Q% >metrics/psq_score.tsv
rm metrics/{base_model_metadata,psq_score,genre_purity}.tmp
