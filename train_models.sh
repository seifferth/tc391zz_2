#!/bin/bash

for c in raw preproc; do    # Train all models on both "raw" and "preproc"

# Confirm that all necessary input files exist
if ! test -f "corpus/$c.tsv.gz"; then
    printf "File '%s' is missing\n" "corpus/$c.tsv.gz" >&2
    exit 1
fi
test -d models/$c || mkdir -p models/$c

train_model() {
    # Args: $1 - Filename for the output model
    #       $2 - Embedding method (passed to ttm embed)
    #       $3 - Dimensionality reduction method (passed to ttm redim)
    test -f "models/$c/$1.tsv.gz" || (
        echo "Training models/$c/$1.tsv.gz from scratch" >&2
        ttm -i corpus/$c.tsv.gz |
            ttm embed --highdim-only $2 |
            ttm redim $3 |
            ttm -o "models/$c/$1.tsv.gz"
    )
}
redim_model() {
    # Args: $1 - Filename for the output model
    #       $2 - Filename for the input model (used to extract embeddings)
    #       $3 - Dimensionality reduction method (passed to ttm redim)
    test -f "models/$c/$1.tsv.gz" || (
        echo "Creating redim_model models/$c/$1.tsv.gz" >&2
        ttm -i "models/$c/$2.tsv.gz" | cut -f1-2 |
            ttm redim $3 |
            ttm -o "models/$c/$1.tsv.gz"
    )
}

# Train multiple topic models based on "corpus/$c.tsv.gz"
#
# 1. Bag of Words and TF-IDF (my own settings)
#
train_model   bow_id-v01        "bow"                             "id"
train_model   bow_umap-v01      "bow"                             "umap"
train_model   tfidf_id-v01      "tfidf"                           "id"
train_model   tfidf_umap-v01    "tfidf"                           "umap"
train_model   bow_id-v02        "bow --min-df=0 --max-df=1"       "id"
train_model   bow_umap-v02      "bow --min-df=0 --max-df=1"       "umap"
train_model   tfidf_id-v02      "tfidf --min-df=0 --max-df=1"     "id"
train_model   tfidf_umap-v02    "tfidf --min-df=0 --max-df=1"     "umap"
train_model   bow_id-v03        "bow --min-df=0 --max-df=.5"      "id"
train_model   bow_umap-v03      "bow --min-df=0 --max-df=.5"      "umap"
train_model   tfidf_id-v03      "tfidf --min-df=0 --max-df=.5"    "id"
train_model   tfidf_umap-v03    "tfidf --min-df=0 --max-df=.5"    "umap"
#
# Check how increasing the umap dimensionality affects tfidf-based models
# (especially in comparison to doc2vec-based ones)
#
redim_model   tfidf_umap-v04    tfidf_umap-v03      "umap --components=50"
redim_model   tfidf_umap-v05    tfidf_umap-v03      "umap --components=100"
redim_model   tfidf_umap-v06    tfidf_umap-v03      "umap --components=10"
redim_model   tfidf_umap-v07    tfidf_umap-v03      "umap --components=20"
#
# 2. lda
#
train_model   lda_id-v01        "lda --vector-size=300"           "id"
train_model   lda_id-v02        "lda --vector-size=100"           "id"
train_model   lda_id-v03        "lda --vector-size=60"            "id"
train_model   lda_id-v04        "lda --vector-size=50"            "id"
#
# Also try 'redim umap' with lda-based models
#
redim_model   lda_umap-v01      lda_id-v01                        "umap"
redim_model   lda_umap-v02      lda_id-v02                        "umap"
redim_model   lda_umap-v03      lda_id-v03                        "umap"
redim_model   lda_umap-v04      lda_id-v04                        "umap"
#
# Try forgoing umap entirely by directly setting the lda "topics" to a
# particularly low number
#
train_model   lda_id-v05        "lda --vector-size=5"             "id"
train_model   lda_id-v06        "lda --vector-size=10"            "id"
train_model   lda_id-v07        "lda --vector-size=20"            "id"
#
# 3. doc2vec
#
train_model   doc2vec_id-v01    "doc2vec --vector-size=300"       "id"
train_model   doc2vec_id-v02    "doc2vec --vector-size=100"       "id"
train_model   doc2vec_id-v03    "doc2vec --vector-size=60"        "id"
#
# Use the same doc2vec models trained above to run 'redim umap' without
# refitting the word embeddings (which would be expensive while not
# offering any clear benefit either)
#
redim_model   doc2vec_umap-v01  doc2vec_id-v01      "umap"
redim_model   doc2vec_umap-v02  doc2vec_id-v02      "umap"
redim_model   doc2vec_umap-v03  doc2vec_id-v03      "umap"
#
# Check if doc2vec+umap models still perform well if lowdim dimensionality
# is higher than five
#
redim_model   doc2vec_umap-v04  doc2vec_id-v01      "umap --components=50"
redim_model   doc2vec_umap-v05  doc2vec_id-v01      "umap --components=100"
redim_model   doc2vec_umap-v06  doc2vec_id-v01      "umap --components=10"
redim_model   doc2vec_umap-v07  doc2vec_id-v01      "umap --components=20"
#
# 4. sbert+umap (aka BERTopic) using the parameters suggested by
#    Maarten Grootendorst (2022) but using multilingual language
#    models rather than on the English-only models used by
#    Grootendorst himself
#
# Multilingual models I could try (as per
# https://www.sbert.net/docs/sentence_transformer/pretrained_models.html):
#
# * distiluse-base-multilingual-cased-v1
# * distiluse-base-multilingual-cased-v2
# * paraphrase-multilingual-MiniLM-L12-v2
# * paraphrase-multilingual-mpnet-base-v2
#
# Note that the pre-trained paraphrase-multilingual-mpnet-base-v2
# will take up roughly 9.1G of disk space below ~/.flair/. The other
# pre-trained multilingual models are also stored in this directory but
# require slightly less disk space.
#
train_model   sbert_umap-v01 \
                    "sbert --model=distiluse-base-multilingual-cased-v1" \
                    "umap --min-dist=0"
train_model   sbert_umap-v02 \
                    "sbert --model=distiluse-base-multilingual-cased-v2" \
                    "umap --min-dist=0"
train_model   sbert_umap-v03 \
                    "sbert --model=paraphrase-multilingual-MiniLM-L12-v2" \
                    "umap --min-dist=0"
train_model   sbert_umap-v04 \
                    "sbert --model=paraphrase-multilingual-mpnet-base-v2" \
                    "umap --min-dist=0"
#
# Also check how these embeddings perform without using umap
#
redim_model   sbert_id-v01    sbert_umap-v01            "id"
redim_model   sbert_id-v02    sbert_umap-v02            "id"
redim_model   sbert_id-v03    sbert_umap-v03            "id"
redim_model   sbert_id-v04    sbert_umap-v04            "id"
#
# Check if using --min-dist=0.1 (as used in the doc2vec+umap models)
# changes anything
#
redim_model  sbert_umap-v01_altmindist  sbert_umap-v01  "umap --min-dist=0.1"
redim_model  sbert_umap-v02_altmindist  sbert_umap-v02  "umap --min-dist=0.1"
redim_model  sbert_umap-v03_altmindist  sbert_umap-v03  "umap --min-dist=0.1"
redim_model  sbert_umap-v04_altmindist  sbert_umap-v04  "umap --min-dist=0.1"

done        # Model training ends here. What follows is clustering, which is
            # only done for the models trained on the preprocessed corpus.

# Create the directory structure for our clustering
test -d clusters || mkdir clusters
test -d clusters/schöch || mkdir clusters/schöch
test -d clusters/preproc || mkdir clusters/preproc
# Run all three clustering algorithms on all models in models/schöch/
# and models/preproc/
for d in schöch preproc; do
    ls "models/$d" | grep "\.tsv\.gz$" | sed 's/\.tsv\.gz$//' |
        while read f; do
            test -f "clusters/$d/$f.kmeans.tsv.gz" || (
                echo "Clustering models/$d/$f.tsv.gz using kmeans" >&2
                ttm -i "models/$d/$f.tsv.gz" cluster kmeans |
                    cut -f1,4 | gzip >"clusters/$d/$f.kmeans.tsv.gz"
            )
            test -f "clusters/$d/$f.aggl.tsv.gz" || (
                echo "Clustering models/$d/$f.tsv.gz using aggl" >&2
                ttm -i "models/$d/$f.tsv.gz" cluster aggl |
                    cut -f1,4 | gzip >"clusters/$d/$f.aggl.tsv.gz"
            )
            test -f "clusters/$d/$f.hdbscan.tsv.gz" || (
                echo "Clustering models/$d/$f.tsv.gz using hdbscan" >&2
                ttm -i "models/$d/$f.tsv.gz" cluster hdbscan |
                    cut -f1,4 | gzip >"clusters/$d/$f.hdbscan.tsv.gz"
            )
        done
done
