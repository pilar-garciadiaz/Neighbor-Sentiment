# Neighbor-Sentiment
Python-MATLAB implementation for flexible feature extraction in Spanish tweet sentiment analysisNeighbor-Sentiment: Flexible Feature Extraction for Spanish Tweet Sentiment Analysis

Overview


Archived software release
The stable software release is preserved in Zenodo.

Version: 1.0.0
GitHub tag: v1.0.0
Version DOI: https://doi.org/10.5281/zenodo.23987283
For exact reproducibility, cite the version DOI.

This repository contains the research software associated with the following article:

> García-Díaz, P., Sánchez-Berriel, I., Pontiel-Martín, D., and González-Ávila, J. L. (2023). 
> A novel flexible feature extraction algorithm for Spanish tweet sentiment analysis based on the context of words.
> Expert Systems with Applications, 212, 118817.  
> https://doi.org/10.1016/j.eswa.2022.118817

The associated research data are available from e-CienciaDatos:

> https://doi.org/10.21950/XEV9IC

The software implements the Neighbor-Sentiment algorithm, a flexible feature extraction and classification method for sentiment analysis of Spanish tweets.

The implementation uses a hybrid Python-MATLAB architecture:

- `feature_combination_14engs.py` is the main executable program;
- the Python program controls the principal experimental workflow;
- the Python program starts MATLAB and invokes the algorithms   implemented in the MATLAB source files;
- the repository contains 23 MATLAB `.m` files;
- the MATLAB components implement data preparation, review creation, individual generation, grouping genetic algorithms, genetic operators, feature combination, classifier evaluation, and word-level classification.

The complete workflow requires Python, MATLAB R2020b, and a compatible installation of the MATLAB Engine API for Python.

The repository is published to support the inspection, preservation, reuse, and reproducibility of the computational methods described in the associated article.


Software architecture

The software follows the workflow below:


Research data
     |
     v
feature_combination_14engs.py
     |
     | MATLAB Engine API for Python
     v
MATLAB R2020b algorithms and functions
     |
     +--> Reading the dictionary and reviews
     |
     +--> Creating the internal review representations
     |
     +--> Generating and grouping individuals
     |
     +--> Applying genetic crossover and mutation
     |
     +--> Performing flexible feature extraction
     |
     +--> Evaluating individual and word-level classifiers
     |
     +--> Applying the Extreme Learning Machine
     |
     +--> Obtaining classification results
     |
     v
Experiment outputs and evaluation metrics


The principal executable is:
feature_combination_14engs.py


The Python program calls the MATLAB functions contained in the 23 `.m` files distributed in this repository.

Users should normally start the complete workflow by executing the Python program. 
Individual MATLAB functions should not be executed in isolation unless their required arguments, dependencies, and expected outputs are known.

Scientific objective

The Neighbor-Sentiment algorithm classifies Spanish-language tweets into four sentiment categories:

- `P`: positive;
- `NEU`: neutral;
- `N`: negative;
- `NONE`: no opinion or no sentiment.

The method combines:

- word-frequency information;
- information related to word entropy;
- the semantic context of words;
- the relative positions of neighboring words;
- flexible feature extraction;
- a grouping genetic algorithm;
- word-level classifiers;
- a voting procedure for final tweet classification.

Unlike conventional feature selection methods, which select a common feature set for all the elements being classified, the proposed method performs a customized feature extraction for each relevant word.

The features selected for each word can therefore differ in both number and identity.


Method summary

Each tweet is represented as a sequence of preprocessed and lemmatized words. 
Each word is associated with a unique identifier in a dictionary.
For a given word, the candidate feature set includes:

1. the word itself;
2. neighboring words up to a maximum distance `Th` to the left;
3. neighboring words up to a maximum distance `Th` to the right;
4. the absolute frequency of the word;
5. the relative frequency of the word in the corpus.


The maximum number of candidate features is:
MaxF = 2 * Th + 3


For the experiments reported in the article:
Th = 5
MaxF = 13


A grouping genetic algorithm selects a customized subset of these features for each word.

Each word and its selected feature set constitute an individual classifier. 
A new tweet is evaluated by the classifiers associated with the relevant words present in the tweet. 
The final sentiment category is determined using a voting procedure.

If a tweet does not contain words represented by sufficiently accurate classifiers, the algorithm may return no classification decision. 
In the article, these cases were considered false negatives when computing the evaluation metrics.


Associated publication

García-Díaz, P., Sánchez-Berriel, I., Pontiel-Martín, D., and González-Ávila, J. L. (2023). 
A novel flexible feature extraction algorithm for Spanish tweet sentiment analysis based on the context of words. 
Expert Systems with Applications, 212, 118817.
https://doi.org/10.1016/j.eswa.2022.118817


Associated research data

The research data associated with the article are preserved in e-CienciaDatos. Dataset DOI: https://doi.org/10.21950/XEV9IC


The complete research dataset is not duplicated in this source-code repository.

Users should obtain the data from the repository of record and comply with the access, citation, licensing, and reuse conditions displayed in the dataset record.

When the data and software are used together, users should cite:

1. the archived software release;
2. the associated research article;
3. the associated dataset.


Corpora and experimental design

The research used Spanish tweets from the TASS sentiment analysis resources.

InterTASS corpus
The InterTASS corpus contains 3,413 tweets distributed into training, development, and testing sets.

The experimental partition described in the article contains:

- 1,008 training tweets;
- 506 development tweets;
- 1,514 training and development tweets in total;
- 1,899 testing tweets.

The testing set is distributed as follows:

| Category | Meaning | Testing tweets |
|---|---|---:|
| `P` | Positive | 642 |
| `NEU` | Neutral | 216 |
| `N` | Negative | 767 |
| `NONE` | No opinion | 274 |
| Total | | 1,899 |


General corpus

The General corpus contains 57,832 tweets.

For the experiments described in the article, the original six polarity categories were converted into four categories:

- strong positive and positive were combined into `P`;
- strong negative and negative were combined into `N`;
- neutral remained `NEU`;
- no opinion remained `NONE`.

The resulting distribution was:

| Category | Number of tweets |
|---|---:|
| `P` | 21,262 |
| `NEU` | 1,300 |
| `N` | 15,124 |
| `NONE` | 20,146 |
| Total | 57,832 |


Published algorithm configuration

The following configuration was reported in the associated article:

| Parameter | Published value |
|---|---:|
| Number of generations | 60 |
| Population size | 50 |
| Crossover method | Two random points |
| Mutation probability | 0.10 |
| Minimum classifier accuracy, `Ac_min` | 0.67 |
| Context threshold, `Th` | 5 |
| Maximum number of candidate features, `MaxF` | 13 |
| Number of sentiment categories | 4 |

These values should be used when attempting to reproduce the experiments reported in the article.

Any differences between these values and the default values included in the source code should be documented in the release notes.


Published results

Training with the InterTASS corpus

| Metric | Value |
|---|---:|
| Precision | 57.76% |
| Recall | 51.39% |
| Macro F1 | 54.39% |
| Accuracy | 61.35% |


Training with the General corpus

| Metric | Value |
|---|---:|
| Precision | 67.85% |
| Recall | 60.66% |
| Macro F1 | 64.06% |
| Accuracy | 68.90% |

The General corpus experiment produced the highest reported Macro F1, with a value of 0.6406, and an accuracy of 0.6890.

Because the method uses a genetic algorithm, results may vary between executions unless the random-number generators used by Python and MATLAB are initialized with fixed seeds.


Repository contents

- one main executable written in Python `feature_combination_14engs.py`;
- 23 MATLAB source files containing the algorithms and supporting functions called by the Python program;
- documentation, citation, licensing, testing, and reproducibility files added for the public software release.

The intended repository structure is:
.
├── README.md
├── LICENSE
├── CITATION.cff
├── CHANGELOG.md
├── feature_combination_14engs.py
├── agrupamiento_individuos.m
├── create_Reviews2.m
├── cruce_individuos.m
├── cruce_individuos_suma.m
├── cruzar_parejas.m
├── elimina_replicas_sustituye.m
├── ELM.m
├── evaluacion_individuo.m
├── evaluacion_word.m
├── evaluation_word_binario.m
├── feature_combination.m
├── generar_individuo.m
├── generar_poblacion_inicial.m
├── genetico.m
├── genetico_winners.m
├── gga_word.m
├── gga_word_binario.m
├── mutacion_indiv_reduce_peores_grupos.m
├── mutacion_individuo.m
├── read_dictionary.m
├── read_reviews1.m
├── read_reviews2.m
├── reparacion_individuo.m


Source files

| File | Language | Role in the software |
|---|---|---|
| `feature_combination_14engs.py` | Python | Main executable and principal workflow controller |
| `agrupamiento_individuos.m` | MATLAB | Groups individuals according to the criteria implemented by the genetic algorithm |
| `create_Reviews2.m` | MATLAB | Creates or transforms the review representations used by the algorithm |
| `cruce_individuos.m` | MATLAB | Implements a crossover operation between individuals |
| `cruce_individuos_suma.m` | MATLAB | Implements the crossover operation identified as `cruce_individuos_suma` |
| `cruzar_parejas.m` | MATLAB | Applies crossover to selected pairs of individuals |
| `elimina_replicas_sustituye.m` | MATLAB | Detects or replaces replicated individuals according to the implemented procedure |
| `ELM.m` | MATLAB | Implements the Extreme Learning Machine component |
| `evaluacion_individuo.m` | MATLAB | Evaluates an individual solution |
| `evaluacion_word.m` | MATLAB | Evaluates a word-level solution or classifier |
| `evaluation_word_binario.m` | MATLAB | Evaluates a word-level binary classifier |
| `feature_combination.m` | MATLAB | Implements the MATLAB feature-combination procedure |
| `generar_individuo.m` | MATLAB | Generates an individual solution |
| `generar_poblacion_inicial.m` | MATLAB | Generates the initial population of the genetic algorithm |
| `genetico.m` | MATLAB | Implements a genetic-algorithm workflow |
| `genetico_winners.m` | MATLAB | Implements the genetic procedure associated with the selected winning solutions |
| `gga_word.m` | MATLAB | Applies the grouping genetic algorithm to word-level feature extraction |
| `gga_word_binario.m` | MATLAB | Applies the grouping genetic algorithm to word-level binary classification |
| `mutacion_indiv_reduce_peores_grupos.m` | MATLAB | Implements the mutation procedure identified by this name |
| `mutacion_individuo.m` | MATLAB | Mutates an individual solution |
| `read_dictionary.m` | MATLAB | Reads the word dictionary used by the algorithm |
| `read_reviews1.m` | MATLAB | Reads review data using the first implemented procedure |
| `read_reviews2.m` | MATLAB | Reads review data using the second implemented procedure |
| `reparacion_individuo.m` | MATLAB | Repairs an individual to satisfy representation or feasibility requirements |


The descriptions in this table are based partly on the source-file names. 
They must be reviewed against the implementation and, where necessary, expanded before the first archived release.

Reference execution environment

| Component | Version or value |
|---|---|
| Main programming language | Python |
| Main executable | `feature_combination_14engs.py` |
| Python version reported in the article | Python 3.8.8 |
| Development environment reported in the article | Spyder 4.2.1 and Anaconda Navigator |
| MATLAB release | MATLAB R2020b |
| Number of MATLAB source files | 23 |
| Python-MATLAB interface | MATLAB Engine API for Python |



Software requirements

Python

The main executable requires Python.

The original Python environment reported in the article was:

Python 3.8.8
Spyder 4.2.1
Anaconda Navigator


The repository contains 23 MATLAB `.m` files. These files are invoked from the main Python program through the MATLAB Engine API for Python.

Compatibility with MATLAB releases other than R2020b has not yet been verified. Users running a different release should report:

- the MATLAB release used;
- the installed toolbox versions;
- any warnings or compatibility errors;
- any differences observed in the experimental results.


MATLAB Engine API for Python

Python must be able to start MATLAB R2020b and invoke the MATLAB functions distributed with the repository.

The MATLAB Engine API for Python must therefore be installed in the same Python environment used to execute `feature_combination_14engs.py`.

No additional MATLAB toolboxes are required.


