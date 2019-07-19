
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
<!-- badges: end -->
**MEteorits:** Mixtures-of-ExperTs modEling for cOmplex and non-noRmal dIsTributions
------------------------------------------------------------------------------------

MEteoritS is an open source toolbox (available in R and Matlab) containg several original and flexible mixtures-of-experts models to model, cluster and classify heteregenous data in many complex situations where the data are distributed according to non-normal and possibly skewed distributions, and when they might be corrupted by atypical observations. The toolbox also contains sparse mixture-of-experts models for high-dimensional data.

Our (dis-)covered meteorits are for instance the following ones:

-   NMoE
-   NNMoE
-   tMoE
-   StMoE
-   SNMoE
-   RMoE

The models and algorithms are developped and written in Matlab by Faicel Chamroukhi, and translated and designed into R packages by Florian Lecocq, Marius Bartcus and Faicel Chamroukhi.

Installation
------------

You can install the development version of MEteorits from [GitHub](https://github.com/fchamroukhi/MEteorits) with:

``` r
# install.packages("devtools")
devtools::install_github("fchamroukhi/MEteorits")
```

To build *vignettes* for examples of usage, type the command below instead:

``` r
# install.packages("devtools")
devtools::install_github("fchamroukhi/MEteorits", 
                         build_opts = c("--no-resave-data", "--no-manual"), 
                         build_vignettes = TRUE)
```

Use the following command to display vignettes:

``` r
browseVignettes("MEteorits")
```

Usage
-----

<details> <summary>NMoE</summary>

``` r
# (fyi: NMoE is for  the standard normal mixture-of-experts model)

library(meteorits)

data("simulatedstructureddata")

K <- 2 # Number of regimes (mixture components)
p <- 1 # Dimension of beta (order of the polynomial regressors)
q <- 1 # Dimension of w (order of the logistic regression: to be set to 1 for segmentation)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

nmoe <- emNMoE(simulatedstructureddata$X, matrix(simulatedstructureddata$Y), K, p, q, n_tries, max_iter, threshold, verbose, verbose_IRLS)

nmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-5-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-5-4.png" style="display: block; margin: auto;" /> </details>

<details> <summary>TMoE</summary>

``` r
library(meteorits)

data("simulatedstructureddata")

K <- 2 # Number of regimes (mixture components)
p <- 1 # Dimension of beta (order of the polynomial regressors)
q <- 1 # Dimension of w (order of the logistic regression: to be set to 1 for segmentation)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

tmoe <- emTMoE(simulatedstructureddata$X, matrix(simulatedstructureddata$Y), K, p, q, n_tries, max_iter, threshold, verbose, verbose_IRLS)

tmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-6-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-4.png" style="display: block; margin: auto;" />

</details>

<details> <summary>SNMoE</summary>

``` r
library(meteorits)

data("simulatedstructureddata")

K <- 2 # Number of regimes (mixture components)
p <- 1 # Dimension of beta (order of the polynomial regressors)
q <- 1 # Dimension of w (order of the logistic regression: to be set to 1 for segmentation)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-6
verbose <- TRUE
verbose_IRLS <- FALSE

snmoe <- emSNMoE(simulatedstructureddata$X, matrix(simulatedstructureddata$Y), 
                 K, p, q, n_tries, max_iter, threshold, verbose, verbose_IRLS)

snmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-7-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-4.png" style="display: block; margin: auto;" /> </details>

<details> <summary>StMoE</summary>

``` r
library(meteorits)

data("simulatedstructureddata")

K <- 2 # Number of regimes (mixture components)
p <- 1 # Dimension of beta (order of the polynomial regressors)
q <- 1 # Dimension of w (order of the logistic regression: to be set to 1 for segmentation)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

stmoe <- emStMoE(simulatedstructureddata$X, matrix(simulatedstructureddata$Y), 
                 K, p, q, n_tries, max_iter, threshold, verbose, verbose_IRLS)

stmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-8-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-4.png" style="display: block; margin: auto;" /> </details>

References
==========

Huynh, Tuyen, and Faicel Chamroukhi. 2019. “Estimation and Feature Selection in Mixtures of Generalized Linear Experts Models.” *Submitted*, july. <https://chamroukhi.com/papers/prEMME.pdf>.

Chamroukhi, F, and Bao T Huynh. 2019. “Regularized Maximum Likelihood Estimation and Feature Selection in Mixtures-of-Experts Models.” *Journal de La Societe Francaise de Statistique* 160(1): 57–85.

Nguyen, Hien D., and F. Chamroukhi. 2018. “Practical and Theoretical Aspects of Mixture-of-Experts Modeling: An Overview.” *Wiley Interdisciplinary Reviews: Data Mining and Knowledge Discovery*, e1246–n/a. <https://doi.org/10.1002/widm.1246>.

Chamroukhi", F. 2017. “Skew T Mixture of Experts.” *Neurocomputing - Elsevier* 266: 390–408. <https://chamroukhi.com/papers/STMoE.pdf>.

Chamroukhi, F. 2016. “Robust Mixture of Experts Modeling Using the *t*-Distribution.” *Neural Networks - Elsevier* 79: 20–36. <https://chamroukhi.com/papers/TMoE.pdf>.

Chamroukhi", F. 2016. “Skew-Normal Mixture of Experts.” In *The International Joint Conference on Neural Networks (Ijcnn)*. <https://chamroukhi.com/papers/Chamroukhi-SNMoE-IJCNN2016.pdf>.

Chamroukhi, F. 2015. “Statistical Learning of Latent Data Models for Complex Data Analysis.” Habilitation Thesis (HDR), Université de Toulon. <https://chamroukhi.com/Dossier/FChamroukhi-Habilitation.pdf>.

Chamroukhi, F. 2010. “Hidden Process Regression for Curve Modeling, Classification and Tracking.” Ph.D. Thesis, Université de Technologie de Compiègne. <https://chamroukhi.com/papers/FChamroukhi-Thesis.pdf>.

Chamroukhi, F., A. Samé, G. Govaert, and P. Aknin. 2009. “Time Series Modeling by a Regression Approach Based on a Latent Process.” *Neural Networks* 22 (5-6): 593–602. <https://chamroukhi.com/papers/Chamroukhi_Neural_Networks_2009.pdf>.
