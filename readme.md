# Digital Appendix: Topic Modelling the Théâtre Classique Collection

This repository serves as the digital appendix to an upcoming article in
the Journal for Computational Literary Studies. I will include a link
to that article once it has been published. This appendix contains the
code and data for the experiments discussed in section 6 "Illustration:
Reassessing the Use of LDA for Modelling the Théâtre Classique
Collection". The tables included below provide a mapping between the
descriptive names used in the article and the somewhat more cryptic
filenames used in this repository. The evaluation metrics discussed
in the article can be found in metrics/euclidean.psq_distance.tsv and
metrics/psq_score.tsv. A detailed analysis of those metrics files will
be added to this repository shortly.


| Descriptive Name        | Filename                                 |
| ----------------------- | ---------------------------------------- |
| TF-IDF & UMAP           | models/preproc/tfidf_umap-v03.tsv.gz     |
| Top2Vec                 | models/preproc/doc2vec_umap-v01.tsv.gz   |
| Bag of Words & UMAP     | models/preproc/bow_umap-v03.tsv.gz       |
| LDA & UMAP              | models/preproc/lda_umap-v04.tsv.gz       |
| Plain LDA               | models/preproc/lda_id-v04.tsv.gz         |
| Schöch’s LDA (best)     | models/schöch/050tp-6000it-0050in.tsv.gz |
| Schöch’s LDA (selected) | models/schöch/060tp-6000it-0300in.tsv.gz |
| BERTopic (best)         | models/preproc/sbert_umap-v04.tsv.gz     |
| Doc2Vec                 | models/preproc/doc2vec_id-v01.tsv.gz     |
| Bag of Words            | models/preproc/bow_id-v03                |
| TF-IDF                  | models/preproc/tfidf_id-v03              |

: Models referenced in Table 1 of the article. Note that some of these
models are also referenced in Figure 7. Visualizations of most models
included in this table can be found in plots/, where the filenames of
the visualizations follow the filenames of models below models/schöch/
and models/preproc/.


| Descriptive Name | Dim. | Filename                               |
| ---------------- | ---: | -------------------------------------- |
| TF-IDF & UMAP    |    5 | models/preproc/tfidf_umap-v03.tsv.gz   |
|                  |   50 | models/preproc/tfidf_umap-v04.tsv.gz   |
|                  |  100 | models/preproc/tfidf_umap-v05.tsv.gz   |
| Top2Vec          |    5 | models/preproc/doc2vec_umap-v01.tsv.gz |
|                  |   50 | models/preproc/doc2vec_umap-v04.tsv.gz |
|                  |  100 | models/preproc/doc2vec_umap-v05.tsv.gz |
| Plain LDA        |    5 | models/preproc/lda_id-v05.tsv.gz       |
|                  |   50 | models/preproc/lda_id-v04.tsv.gz       |
|                  |  100 | models/preproc/lda_id-v02.tsv.gz       |

: Models referenced in Table 2 of the article.


| Descriptive Name      | Filename                                          |
| --------------------- | ------------------------------------------------- |
| TF-IDF & UMAP & Aggl. | clusters/preproc/tfidf_umap-v03.aggl.tsv.gz       |
| TF-IDF & Aggl.        | clusters/preproc/tfidf_id-v03.aggl.tsv.gz         |
| Top2Vec               | clusters/preproc/doc2vec_umap-v01.hdbscan.tsv.gz  |
| LDA & K-Means         | clusters/schöch/060tp-6000it-1000in.kmeans.tsv.gz |
| Bag of Words & UMAP … | clusters/preproc/bow_umap-v03.aggl.tsv.gz         |
| LDA & Aggl.           | clusters/schöch/090tp-6000it-7000in.aggl.tsv.gz   |
| Bag of Words & Aggl.  | clusters/preproc/bow_id-v03.aggl.tsv.gz           |
| BERTopic (best’)      | clusters/preproc/sbert_umap-v02.hdbscan.tsv.gz    |

: Models referenced in Table 3 of the article.


## License

The corpus stored in corpus/ consists of French plays from the 17th and
18th centuries which, due to their age, are within the public domain. They
were initially retrieved from the Théâtre Classique collection (Fièvre
2007–2025) by Christof Schöch for his work on "Topic Modeling Genre"
(2017). Since the corpus itself is within the public domain, it is not
subject to any copyright restrictions.

The topic models and clusters in models/schöch/ and clusters/schöch-agg/
were initially created by Christof Schöch (2017) and are licensed
under the [CC0] license, albeit with an additional note indicating that
a link to his work would be appreciated. All remaining topic models
were created by myself and may be freely reused under the terms of the
[CC BY 4.0] license. Some scripts in utils/ are based on source code
that was originally written by Christof Schöch and that is likewise
licensed under a [CC0] license. Where applicable, this relationship is
made explicit in the initial comment of the script in question. Just
like the topic models I created, all scripts contained in this repository
– whether original or whether based on earlier work – may be freely
reused under the terms of the [CC BY 4.0] license.

[CC0]: https://creativecommons.org/publicdomain/zero/1.0/
[CC BY 4.0]: https://creativecommons.org/licenses/by/4.0/


## Relationship to Other Peoples' Work

Some of the data contained in this repository was either strongly inspired
by or even directly converted from other peoples' work. The files stored
in corpus/ were directly converted from the digital appendix of Christof
Schöch's (2017) article on "Topic Modeling Genre". Christof Schöch, in
turn, relied on the Théâtre Classique collection (Fièvre 2007–2025)
to obtain a copy of the works that make up this corpus. The models
stored in models/schöch/ were also directly converted from the appendix
of Schöch's article, and those in models/schöch-agg/ were strongly
inspired by his work. The clusters found in clusters/schöch-agg/ are
based on the clustering found in Figure 11 of Schöch's article.

The models whose name starts with "doc2vec_umap" were directly
inspired by Dimo Angelov's (2020) Top2Vec. Of these models, those
called "doc2vec_umap-v01" use the same metaparameter settings used
by Angelov himself, while the others represent slight variations
of those metaparameter settings. For clustering, Angelov uses
the Accelerated HDBSCAN algorithm proposed by Leland McInnes and
John Healy (2017). The clusters found in the various files whose
name contains "hdbscan" were created using the same algorithm and
metaparameter settings used by Angelov. The clustering found in
"clusters/preproc/doc2vec_umap-v01.hdbscan.tsv.gz" is the result of a
direct application of Dimo Angelov's (2020) Top2Vec to the corpus that
was investigated – and preprocessed – by Christof Schöch (2017).

The various models whose name starts with "sbert_umap" were strongly
inspired by Maarten Grootendorst's (2022) BERTopic. Grootendorst's
approach relies on using pre-trained language models for generating
document embeddings that are then processed in a way that strongly
resembles Dimo Angelov's (2020) Top2Vec. Since Grootendorst himself uses
monolingual language models trained only on English texts, it would have
made little sense to apply the same models to the corpus investigated
in this study, which consists entirely of French texts. The various
"sbert_umap" models are therefore based on pre-trained multilingual
language models which were also trained on French language data and which
should therefore be better suited for embedding French documents. The
general architecture used for creating those multilingual language models
(Reimers and Gurevych 2020) is closely related to the architecture of the
language models used by Grootendorst himself (Reimers and Gurevych 2019).

Finally, the algorithms that were used for generating topic models were
also both designed and implemented by other people. For the implementation
see the dependencies of ttm. For the embedding and dimensionality
reduction algorithms see Blei et al. (2001, 2003) for LDA, Le and Mikolov
(2014) for Doc2Vec, Reimers and Gurevych (2019, 2020) for Sentence-BERT,
and McInnes et al. (2020) for UMAP. For the clustering algorithms see
McInnes and Healy (2017) for Accelerated HDBSCAN, as well as the online
documentation of Scikit-Learn (Pedregosa et al. 2011) for details on
the two schoolbook approaches K-Means and Agglomerative Clustering.


## Reproducing the Experiments

The experiments were performed – and could thus be reproduced – by
running the following scripts:

    ./prepare_corpus.sh     # Git clone the digital appendix of Christof
                            # Schöch's (2017) article on "Topic Modeling
                            # Genre" and store the relevant pieces in
                            # corpus/.
    ./convert_models.sh     # Convert the topic models trained by Christof
                            # Schöch into the format used by ttm and store
                            # them in models/schöch/ and clusters/schöch-agg/.
                            # Also create a number of aggregated topic models
                            # in models/schöch-agg/.
    ./train_models.sh       # Train a number of additional topic models and
                            # store them below models/ and clusters/.
    ./eval.sh               # Calculate a number of evaluation metrics and
                            # store aggregated lists of those metrics in
                            # metrics/.
    ./plot.sh               # Visualize a number of manually selected topic
                            # models using PCA-based scatterplots and store
                            # the results in plots/.

Since training topic models can be somewhat time-consuming, these
scripts will not recreate files that already exist; save for a few
exceptions related to combining already computed evaluation metrics and
plots. In order to reproduce all data from scratch, one would need to
remove the following directories: corpus/, models/, clusters/, metrics/,
and plots/. Also note that the scripts do not double-check the validity
of output files. In case of errors, corrupted output files need to be
removed manually.


## Dependencies

The scripts mentioned in the previous section have the following
dependencies:

* A POSIX-compatible scripting environment including bash (the scripts
  were developed and executed on debian 12 bookworm)
* git
* python3
* csvkit (https://github.com/wireservice/csvkit/)
* ttm (https://github.com/seifferth/ttm/), including all its dependencies
* A number of task-specific helper scripts in utils/, which in turn depend
  on the following python packages: pandas, numpy, scikit-learn, pygal


## References

Angelov, Dimo (2021). "Top2Vec. Distributed Representations of Topics".
In: arXiv preprint. DOI: 10.48550/arXiv.2008.09470.

Blei, David M., Andrew Y. Ng, and Michael I. Jordan (2001). "Latent Dirichlet
Allocation". In: Advances in Neural Information Processing Systems. URL:
https://proceedings.neurips.cc/paper_files/paper/2001/file/296472c9542ad4d4788d543508116cbc-Paper.pdf.

— (2003). "Latent Dirichlet Allocation". In: Journal
of Machine Learning Research 3, 993–1022. URL:
https://www.jmlr.org/papers/volume3/blei03a/blei03a.pdf.

Fièvre, Paul, ed. (2007–2025). Théâtre Classique. URL:
https://theatre-classique.fr/.

Grootendorst, Maarten (2022). "BERTopic. Neural Topic Modeling
with a Class-Based TF-IDF Procedure". In: arXiv preprint. DOI:
10.48550/arXiv.2203.05794.

Le, Quoc and Tomas Mikolov (2014). "Distributed Representations of
Sentences and Documents". In: Proceedings of the 31st International
Conference on Machine Learning. Vol. 32. 2, 1188–1196. URL:
https://proceedings.mlr.press/v32/le14.pdf.

McInnes, Leland and John Healy (2017). "Accelerated Hierarchical Density
Based Clustering". In: 2017 IEEE International Conference on Data Mining
Workshops, 33–42. DOI: 10.1109/icdmw.2017.12.

McInnes, Leland, John Healy, and James Melville (2020). "UMAP. Uniform
Manifold Approximation and Projection for Dimension Reduction". In: arXiv
preprint. DOI: 10.48550/arXiv.1802.03426.

Pedregosa, Fabian, Gaël Varoquaux, Alexandre Gramfort, Vincent Michel,
Bertrand Thirion, Olivier Grisel, et al. (2011). "Scikit-Learn. Machine
Learning in Python". Journal of Machine Learning Research 12, 2825–2830. URL:
https://jmlr.csail.mit.edu/papers/volume12/pedregosa11a/pedregosa11a.pdf.

Reimers, Nils and Iryna Gurevych (2019). "Sentence-BERT. Sentence Embeddings
Using Siamese BERT-Networks". In: Proceedings of the 2019 Conference on
Empirical Methods in Natural Language Processing and the 9th International
Joint Conference on Natural Language Processing. Association for Computational
Linguistics. DOI: 10.18653/v1/D19-1410.

— (2020). "Making Monolingual Sentence Embeddings Multilingual Using
Knowledge Distillation". In: Proceedings of the 2020 Conference on Empirical
Methods in Natural Language Processing. Association for Computational
Linguistics. DOI: 10.18653/v1/2020.emnlp-main.365.

Schöch, Christof (2017). "Topic Modeling Genre. An Exploration of French
Classical and Enlightenment Drama". In: Digital Humanities Quarterly 11.2.
URL: https://www.digitalhumanities.org/dhq/vol/11/2/000291/000291.html.
