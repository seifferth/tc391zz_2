#!/bin/bash

# Retrieve the data used by Schöch (2017)
test -d projects || (
    git clone https://github.com/cligs/projects
    cd projects
    git checkout v0.3.1
)

# Convert the corpus to the tsv format used by ttm
#
# 1. Reproducing the exact segmentation used by Schöch (2017) but not
#    the entire preprocessing pipeline
test -d corpus || mkdir corpus
test -f corpus/raw.tsv.gz || (
    echo Creating corpus/raw.tsv.gz >&2
    printf 'id\tn_tokens\tn_chars\tcontent\n'
    ls projects/2015/gddh/2_segs/* |
        while read f; do
            printf '%s' "$f" | sed 's|.*/||' | tr -d '\n'; printf '\t'
            cat "$f" | wc -w | tr -d '\n'; printf '\t'
            cat "$f" | wc -c | tr -d '\n'; printf '\t'
            cat "$f" | tr '\n' ' ' | sed 's/ *$//'; printf '\n'
        done
) | gzip >corpus/raw.tsv.gz
test -f corpus/psq_pairs.tsv || (
    echo Creating corpus/psq_pairs.tsv >&2
    paste \
        <(echo N§A; ls projects/2015/gddh/2_segs/) \
        <(ls projects/2015/gddh/2_segs/; echo N§A) |
        sed 's/§/\t/g' |
        awk '$1 == $3 {print $1 "§" $2 "\t" $3 "§" $4}'
) >corpus/psq_pairs.tsv
#
# 2. Reproducing the exact preprocessing used by Schöch (2017) including
#    segmentation, lemmatization and POS-based filtering
test -f corpus/preproc.tsv.gz || (
    echo Creating corpus/preproc.tsv.gz >&2
    printf 'id\tn_tokens\tn_chars\tcontent\n'
    ls projects/2015/gddh/5_lemmata/*.txt |
        while read f; do
            printf '%s' "$f" | sed 's|.*/||' | tr -d '\n'; printf '\t'
            cat "$f" | wc -w | tr -d '\n'; printf '\t'
            cat "$f" | wc -c | tr -d '\n'; printf '\t'
            cat "$f" | tr '\n' ' ' | sed 's/ *$//'; printf '\n'
        done
) | gzip >corpus/preproc.tsv.gz
# The psq pairs should be the same as corpus.psq, so we can just use
# that file for all tests. However, we should still ensure that the
# pairs actually match.
if ! cmp corpus/psq_pairs.tsv <(
    paste \
        <(echo N§A; ls projects/2015/gddh/5_lemmata/) \
        <(ls projects/2015/gddh/5_lemmata/; echo N§A) |
        sed 's/§/\t/g' |
        awk '$1 == $3 {print $1 "§" $2 "\t" $3 "§" $4}'
); then
    echo "Aborting due to unexpected mismatch between corpus segmentation" \
         "in 2_segs/ and 5_lemmata/" >&2
    exit 1
fi

# Extract the relevant metadata from Schöch's "mastermatrix"
test -f corpus/genre_metadata.tsv || (
    echo Creating corpus/genre_metadata.tsv >&2
    csvsql --no-inference \
        projects/2015/gddh/9_aggregates/060tp-0300in/mastermatrix.csv \
        --query '
            with genre_metadata as (
                select
                    printf("%s.txt", segmentID) as id,
                    tc_subgenre as genre
                from mastermatrix
                union select
                    idno as id,
                    group_concat(distinct tc_subgenre) as genre
                from mastermatrix group by idno
            )
            select
                id as id,
                case
                    when genre = "Comédie"       then "comedies"
                    when genre = "Tragi-comédie" then "tragicomedies"
                    when genre = "Tragédie"      then "tragedies"
                    else                              "N/A"
                end as genre
            from genre_metadata
        ' | csvformat -T -U3 >corpus/genre_metadata.tsv
)

# Finally, reproduce the data displayed in Figure 11 of Schöch's
# article. Since Schöch's repository does not seem to contain a
# machine-readable version of that data, I manually copied the data
# into a tsv-formatted table which I simply inline into this script in
# a compressed format:
test -f corpus/figure11.tsv || (
    echo Creating corpus/figure11.tsv >&2
cat <<EOF | base64 -d | gunzip >corpus/figure11.tsv
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
f/sgf5D5JQAA
EOF
)
