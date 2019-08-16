
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/fchamroukhi/MEteorits.svg?branch=master)](https://travis-ci.org/fchamroukhi/MEteorits)
<!-- badges: end -->

# **MEteorits:** Mixtures-of-ExperTs modEling for cOmplex and non-noRmal dIsTributions

MEteoritS is an open source toolbox (available in R and Matlab) containg
several original and flexible mixtures-of-experts models to model,
cluster and classify heteregenous data in many complex situations where
the data are distributed according to non-normal and possibly skewed
distributions, and when they might be corrupted by atypical
observations. The toolbox also contains sparse mixture-of-experts models
for high-dimensional data.

Our (dis-)covered meteorits are for instance the following ones:

  - NMoE;
  - tMoE;
  - SNMoE;
  - StMoE.

The models and algorithms are developped and written in Matlab by Faicel
Chamroukhi, and translated and designed into R packages by Florian
Lecocq, Marius Bartcus and Faicel Chamroukhi.

# Installation

You can install the development version of MEteorits from
[GitHub](https://github.com/fchamroukhi/MEteorits) with:

``` r
# install.packages("devtools")
devtools::install_github("fchamroukhi/MEteorits")
```

To build *vignettes* for examples of usage, type the command below
instead:

``` r
# install.packages("devtools")
devtools::install_github("fchamroukhi/MEteorits", 
                         build_opts = c("--no-resave-data", "--no-manual"), 
                         build_vignettes = TRUE)
```

Use the following command to display vignettes:

``` r
browseVignettes("meteorits")
```

# Usage

``` r
library(meteorits)
```

<details>

<summary>NMoE</summary>

``` r
# Application to a simuated data set

n <- 500 # Size of the sample
alphak <- matrix(c(0, 8), ncol = 1) # Parameters of the gating network
betak <- matrix(c(0, -2.5, 0, 2.5), ncol = 2) # Regression coefficients of the experts
sigmak <- c(1, 1) # Standard deviations of the experts
x <- seq.int(from = -1, to = 1, length.out = n) # Inputs (predictors)

# Generate sample of size n
sample <- sampleUnivNMoE(alphak = alphak, betak = betak, sigmak = sigmak, x = x)
y <- matrix(sample$y)

K <- 2 # Number of regressors/experts
p <- 1 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

nmoe <- emNMoE(X = x, Y = y, K, p, q, n_tries, max_iter, 
               threshold, verbose, verbose_IRLS)
#> EM NMoE: Iteration: 1 | log-likelihood: -834.669412265901
#> EM NMoE: Iteration: 2 | log-likelihood: -834.378024102628
#> EM NMoE: Iteration: 3 | log-likelihood: -833.843668649798
#> EM NMoE: Iteration: 4 | log-likelihood: -832.609489223083
#> EM NMoE: Iteration: 5 | log-likelihood: -829.746089432789
#> EM NMoE: Iteration: 6 | log-likelihood: -823.501855976918
#> EM NMoE: Iteration: 7 | log-likelihood: -811.44201289414
#> EM NMoE: Iteration: 8 | log-likelihood: -792.039041694122
#> EM NMoE: Iteration: 9 | log-likelihood: -767.207358496076
#> EM NMoE: Iteration: 10 | log-likelihood: -742.920502155911
#> EM NMoE: Iteration: 11 | log-likelihood: -725.617378047228
#> EM NMoE: Iteration: 12 | log-likelihood: -716.383995372931
#> EM NMoE: Iteration: 13 | log-likelihood: -712.073882185548
#> EM NMoE: Iteration: 14 | log-likelihood: -710.07937914157
#> EM NMoE: Iteration: 15 | log-likelihood: -709.130846367204
#> EM NMoE: Iteration: 16 | log-likelihood: -708.663168178992
#> EM NMoE: Iteration: 17 | log-likelihood: -708.423672349157
#> EM NMoE: Iteration: 18 | log-likelihood: -708.296339308418
#> EM NMoE: Iteration: 19 | log-likelihood: -708.226062274771
#> EM NMoE: Iteration: 20 | log-likelihood: -708.185785204802
#> EM NMoE: Iteration: 21 | log-likelihood: -708.161807519434
#> EM NMoE: Iteration: 22 | log-likelihood: -708.146986214953
#> EM NMoE: Iteration: 23 | log-likelihood: -708.137487408786
#> EM NMoE: Iteration: 24 | log-likelihood: -708.131192262403

nmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-6-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-4.png" style="display: block; margin: auto;" />

``` r
# Application to a real data set

data("tempanomalies")
x <- tempanomalies$Year
y <- as.matrix(tempanomalies$AnnualAnomaly)

K <- 2 # Number of regressors/experts
p <- 1 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

nmoe <- emNMoE(X = x, Y = y, K, p, q, n_tries, max_iter, 
               threshold, verbose, verbose_IRLS)
#> EM NMoE: Iteration: 1 | log-likelihood: 48.7720650918432
#> EM NMoE: Iteration: 2 | log-likelihood: 49.8845374806081
#> EM NMoE: Iteration: 3 | log-likelihood: 52.273392814906
#> EM NMoE: Iteration: 4 | log-likelihood: 57.5966744888489
#> EM NMoE: Iteration: 5 | log-likelihood: 66.0179285729516
#> EM NMoE: Iteration: 6 | log-likelihood: 73.6124010033139
#> EM NMoE: Iteration: 7 | log-likelihood: 77.765339903292
#> EM NMoE: Iteration: 8 | log-likelihood: 80.3538481482526
#> EM NMoE: Iteration: 9 | log-likelihood: 83.1665948878439
#> EM NMoE: Iteration: 10 | log-likelihood: 86.9905690172863
#> EM NMoE: Iteration: 11 | log-likelihood: 91.6122895402568
#> EM NMoE: Iteration: 12 | log-likelihood: 94.7701853443069
#> EM NMoE: Iteration: 13 | log-likelihood: 95.8957666662934
#> EM NMoE: Iteration: 14 | log-likelihood: 96.2799921075351
#> EM NMoE: Iteration: 15 | log-likelihood: 96.452016072651
#> EM NMoE: Iteration: 16 | log-likelihood: 96.56294379746
#> EM NMoE: Iteration: 17 | log-likelihood: 96.6588827279579
#> EM NMoE: Iteration: 18 | log-likelihood: 96.7554373799238
#> EM NMoE: Iteration: 19 | log-likelihood: 96.8582613216701
#> EM NMoE: Iteration: 20 | log-likelihood: 96.9690127713058
#> EM NMoE: Iteration: 21 | log-likelihood: 97.0871658288271
#> EM NMoE: Iteration: 22 | log-likelihood: 97.2106921559598
#> EM NMoE: Iteration: 23 | log-likelihood: 97.3365772125933
#> EM NMoE: Iteration: 24 | log-likelihood: 97.4614784249611
#> EM NMoE: Iteration: 25 | log-likelihood: 97.5825356336814
#> EM NMoE: Iteration: 26 | log-likelihood: 97.6981535594454
#> EM NMoE: Iteration: 27 | log-likelihood: 97.8085171971002
#> EM NMoE: Iteration: 28 | log-likelihood: 97.9156381629038
#> EM NMoE: Iteration: 29 | log-likelihood: 98.0228514845093
#> EM NMoE: Iteration: 30 | log-likelihood: 98.133940026578
#> EM NMoE: Iteration: 31 | log-likelihood: 98.2521778378392
#> EM NMoE: Iteration: 32 | log-likelihood: 98.3796597035185
#> EM NMoE: Iteration: 33 | log-likelihood: 98.5171703825266
#> EM NMoE: Iteration: 34 | log-likelihood: 98.6646237176447
#> EM NMoE: Iteration: 35 | log-likelihood: 98.821782331821
#> EM NMoE: Iteration: 36 | log-likelihood: 98.9889644284955
#> EM NMoE: Iteration: 37 | log-likelihood: 99.1674845563336
#> EM NMoE: Iteration: 38 | log-likelihood: 99.359891515319
#> EM NMoE: Iteration: 39 | log-likelihood: 99.5702277666056
#> EM NMoE: Iteration: 40 | log-likelihood: 99.804578685113
#> EM NMoE: Iteration: 41 | log-likelihood: 100.072112043091
#> EM NMoE: Iteration: 42 | log-likelihood: 100.386668024682
#> EM NMoE: Iteration: 43 | log-likelihood: 100.768270777819
#> EM NMoE: Iteration: 44 | log-likelihood: 101.23983751416
#> EM NMoE: Iteration: 45 | log-likelihood: 101.79768588596
#> EM NMoE: Iteration: 46 | log-likelihood: 102.329750038347
#> EM NMoE: Iteration: 47 | log-likelihood: 102.634195767625
#> EM NMoE: Iteration: 48 | log-likelihood: 102.720956845916
#> EM NMoE: Iteration: 49 | log-likelihood: 102.721021481919

nmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-7-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-4.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>TMoE</summary>

``` r
# Application to a simuated data set

n <- 500 # Size of the sample
alphak <- matrix(c(0, 8), ncol = 1) # Parameters of the gating network
betak <- matrix(c(0, -2.5, 0, 2.5), ncol = 2) # Regression coefficients of the experts
sigmak <- c(0.5, 0.5) # Standard deviations of the experts
nuk <- c(5, 7) # Degrees of freedom of the experts network t densities
x <- seq.int(from = -1, to = 1, length.out = n) # Inputs (predictors)

# Generate sample of size n
sample <- sampleUnivTMoE(alphak = alphak, betak = betak, sigmak = sigmak, 
                         nuk = nuk, x = x)
y <- matrix(sample$y)

K <- 2 # Number of regressors/experts
p <- 1 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

tmoe <- emTMoE(X = x, Y = y, K, p, q, n_tries, max_iter, 
               threshold, verbose, verbose_IRLS)
#> EM - tMoE: Iteration: 1 | log-likelihood: -503.694996129468
#> EM - tMoE: Iteration: 2 | log-likelihood: -496.007553229401
#> EM - tMoE: Iteration: 3 | log-likelihood: -495.678379737417
#> EM - tMoE: Iteration: 4 | log-likelihood: -495.505586421854
#> EM - tMoE: Iteration: 5 | log-likelihood: -495.374114733176
#> EM - tMoE: Iteration: 6 | log-likelihood: -495.274228619371
#> EM - tMoE: Iteration: 7 | log-likelihood: -495.198892435884
#> EM - tMoE: Iteration: 8 | log-likelihood: -495.1424271988
#> EM - tMoE: Iteration: 9 | log-likelihood: -495.100327044175
#> EM - tMoE: Iteration: 10 | log-likelihood: -495.069073616988
#> EM - tMoE: Iteration: 11 | log-likelihood: -495.045956985074
#> EM - tMoE: Iteration: 12 | log-likelihood: -495.028911902866
#> EM - tMoE: Iteration: 13 | log-likelihood: -495.016375270887
#> EM - tMoE: Iteration: 14 | log-likelihood: -495.007174393918
#> EM - tMoE: Iteration: 15 | log-likelihood: -495.000433875452
#> EM - tMoE: Iteration: 16 | log-likelihood: -494.995503301163

tmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-8-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-4.png" style="display: block; margin: auto;" />

``` r
# Application to a real data set

library(MASS)
data("mcycle")
x <- mcycle$times
y <- as.matrix(mcycle$accel)

K <- 4 # Number of regressors/experts
p <- 2 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

tmoe <- emTMoE(X = x, Y = y, K, p, q, n_tries, max_iter, 
               threshold, verbose, verbose_IRLS)
#> EM - tMoE: Iteration: 1 | log-likelihood: -584.230811458158
#> EM - tMoE: Iteration: 2 | log-likelihood: -583.499946931831
#> EM - tMoE: Iteration: 3 | log-likelihood: -582.845523000393
#> EM - tMoE: Iteration: 4 | log-likelihood: -580.048968884322
#> EM - tMoE: Iteration: 5 | log-likelihood: -570.835235880071
#> EM - tMoE: Iteration: 6 | log-likelihood: -563.398395552807
#> EM - tMoE: Iteration: 7 | log-likelihood: -560.481641230549
#> EM - tMoE: Iteration: 8 | log-likelihood: -559.818686169742
#> EM - tMoE: Iteration: 9 | log-likelihood: -559.279787915395
#> EM - tMoE: Iteration: 10 | log-likelihood: -558.599420676847
#> EM - tMoE: Iteration: 11 | log-likelihood: -557.766364387109
#> EM - tMoE: Iteration: 12 | log-likelihood: -556.794854621896
#> EM - tMoE: Iteration: 13 | log-likelihood: -555.778914665037
#> EM - tMoE: Iteration: 14 | log-likelihood: -554.858511414142
#> EM - tMoE: Iteration: 15 | log-likelihood: -554.056540879602
#> EM - tMoE: Iteration: 16 | log-likelihood: -553.348493454933
#> EM - tMoE: Iteration: 17 | log-likelihood: -552.747200798671
#> EM - tMoE: Iteration: 18 | log-likelihood: -552.273873754062
#> EM - tMoE: Iteration: 19 | log-likelihood: -551.929110257812
#> EM - tMoE: Iteration: 20 | log-likelihood: -551.69252352127
#> EM - tMoE: Iteration: 21 | log-likelihood: -551.53597956088
#> EM - tMoE: Iteration: 22 | log-likelihood: -551.434276498625
#> EM - tMoE: Iteration: 23 | log-likelihood: -551.368609159656
#> EM - tMoE: Iteration: 24 | log-likelihood: -551.326181426302
#> EM - tMoE: Iteration: 25 | log-likelihood: -551.298628196955
#> EM - tMoE: Iteration: 26 | log-likelihood: -551.280595117925
#> EM - tMoE: Iteration: 27 | log-likelihood: -551.26867764508
#> EM - tMoE: Iteration: 28 | log-likelihood: -551.260711120397
#> EM - tMoE: Iteration: 29 | log-likelihood: -551.25531471284

tmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-9-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-9-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-9-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-9-4.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>SNMoE</summary>

``` r
# Application to a simulated data set

n <- 500 # Size of the sample
alphak <- matrix(c(0, 8), ncol = 1) # Parameters of the gating network
betak <- matrix(c(0, -2.5, 0, 2.5), ncol = 2) # Regression coefficients of the experts
lambdak <- c(3, 5) # Skewness parameters of the experts
sigmak <- c(1, 1) # Standard deviations of the experts
x <- seq.int(from = -1, to = 1, length.out = n) # Inputs (predictors)

# Generate sample of size n
sample <- sampleUnivSNMoE(alphak = alphak, betak = betak, sigmak = sigmak, 
                          lambdak = lambdak, x = x)
y <- matrix(sample$y)

K <- 2 # Number of regressors/experts
p <- 1 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-6
verbose <- TRUE
verbose_IRLS <- FALSE

snmoe <- emSNMoE(X = x, Y = y, K, p, q, n_tries, max_iter, 
                 threshold, verbose, verbose_IRLS)
#> EM - SNMoE: Iteration: 1 | log-likelihood: -623.736129174978
#> EM - SNMoE: Iteration: 2 | log-likelihood: -529.971985605855
#> EM - SNMoE: Iteration: 3 | log-likelihood: -526.446673495481
#> EM - SNMoE: Iteration: 4 | log-likelihood: -525.787766275884
#> EM - SNMoE: Iteration: 5 | log-likelihood: -525.566128871218
#> EM - SNMoE: Iteration: 6 | log-likelihood: -525.411842455541
#> EM - SNMoE: Iteration: 7 | log-likelihood: -525.267453901195
#> EM - SNMoE: Iteration: 8 | log-likelihood: -525.129308258163
#> EM - SNMoE: Iteration: 9 | log-likelihood: -525.000103308395
#> EM - SNMoE: Iteration: 10 | log-likelihood: -524.881433486385
#> EM - SNMoE: Iteration: 11 | log-likelihood: -524.773550779129
#> EM - SNMoE: Iteration: 12 | log-likelihood: -524.675946426852
#> EM - SNMoE: Iteration: 13 | log-likelihood: -524.587774956282
#> EM - SNMoE: Iteration: 14 | log-likelihood: -524.508188682295
#> EM - SNMoE: Iteration: 15 | log-likelihood: -524.43626173752
#> EM - SNMoE: Iteration: 16 | log-likelihood: -524.371205900727
#> EM - SNMoE: Iteration: 17 | log-likelihood: -524.312312650983
#> EM - SNMoE: Iteration: 18 | log-likelihood: -524.258872997736
#> EM - SNMoE: Iteration: 19 | log-likelihood: -524.210349337252
#> EM - SNMoE: Iteration: 20 | log-likelihood: -524.166241042219
#> EM - SNMoE: Iteration: 21 | log-likelihood: -524.126001914842
#> EM - SNMoE: Iteration: 22 | log-likelihood: -524.089253379723
#> EM - SNMoE: Iteration: 23 | log-likelihood: -524.055624682844
#> EM - SNMoE: Iteration: 24 | log-likelihood: -524.024821758202
#> EM - SNMoE: Iteration: 25 | log-likelihood: -523.996553491764
#> EM - SNMoE: Iteration: 26 | log-likelihood: -523.970575809706
#> EM - SNMoE: Iteration: 27 | log-likelihood: -523.946691917607
#> EM - SNMoE: Iteration: 28 | log-likelihood: -523.924644892691
#> EM - SNMoE: Iteration: 29 | log-likelihood: -523.904298284591
#> EM - SNMoE: Iteration: 30 | log-likelihood: -523.88548373268
#> EM - SNMoE: Iteration: 31 | log-likelihood: -523.868052798761
#> EM - SNMoE: Iteration: 32 | log-likelihood: -523.851883028784
#> EM - SNMoE: Iteration: 33 | log-likelihood: -523.836858235452
#> EM - SNMoE: Iteration: 34 | log-likelihood: -523.82287738478
#> EM - SNMoE: Iteration: 35 | log-likelihood: -523.809845183224
#> EM - SNMoE: Iteration: 36 | log-likelihood: -523.797671621966
#> EM - SNMoE: Iteration: 37 | log-likelihood: -523.7862706333
#> EM - SNMoE: Iteration: 38 | log-likelihood: -523.77559680011
#> EM - SNMoE: Iteration: 39 | log-likelihood: -523.765582526406
#> EM - SNMoE: Iteration: 40 | log-likelihood: -523.756158747604
#> EM - SNMoE: Iteration: 41 | log-likelihood: -523.747287948318
#> EM - SNMoE: Iteration: 42 | log-likelihood: -523.738939469126
#> EM - SNMoE: Iteration: 43 | log-likelihood: -523.731027442113
#> EM - SNMoE: Iteration: 44 | log-likelihood: -523.723501868707
#> EM - SNMoE: Iteration: 45 | log-likelihood: -523.716369958088
#> EM - SNMoE: Iteration: 46 | log-likelihood: -523.709602272817
#> EM - SNMoE: Iteration: 47 | log-likelihood: -523.703177945963
#> EM - SNMoE: Iteration: 48 | log-likelihood: -523.697031219898
#> EM - SNMoE: Iteration: 49 | log-likelihood: -523.691142838632
#> EM - SNMoE: Iteration: 50 | log-likelihood: -523.685510317967
#> EM - SNMoE: Iteration: 51 | log-likelihood: -523.680084509423
#> EM - SNMoE: Iteration: 52 | log-likelihood: -523.674859827417
#> EM - SNMoE: Iteration: 53 | log-likelihood: -523.669838447135
#> EM - SNMoE: Iteration: 54 | log-likelihood: -523.664975964321
#> EM - SNMoE: Iteration: 55 | log-likelihood: -523.660261039489
#> EM - SNMoE: Iteration: 56 | log-likelihood: -523.655683100821
#> EM - SNMoE: Iteration: 57 | log-likelihood: -523.651236735341
#> EM - SNMoE: Iteration: 58 | log-likelihood: -523.646911115598
#> EM - SNMoE: Iteration: 59 | log-likelihood: -523.642687751603
#> EM - SNMoE: Iteration: 60 | log-likelihood: -523.638551914439
#> EM - SNMoE: Iteration: 61 | log-likelihood: -523.634507411951
#> EM - SNMoE: Iteration: 62 | log-likelihood: -523.630529893297
#> EM - SNMoE: Iteration: 63 | log-likelihood: -523.626624036496
#> EM - SNMoE: Iteration: 64 | log-likelihood: -523.622786125148
#> EM - SNMoE: Iteration: 65 | log-likelihood: -523.61901298054
#> EM - SNMoE: Iteration: 66 | log-likelihood: -523.615300300199
#> EM - SNMoE: Iteration: 67 | log-likelihood: -523.611648768106
#> EM - SNMoE: Iteration: 68 | log-likelihood: -523.608048622372
#> EM - SNMoE: Iteration: 69 | log-likelihood: -523.604499081908
#> EM - SNMoE: Iteration: 70 | log-likelihood: -523.600994757408
#> EM - SNMoE: Iteration: 71 | log-likelihood: -523.597539253721
#> EM - SNMoE: Iteration: 72 | log-likelihood: -523.594143616033
#> EM - SNMoE: Iteration: 73 | log-likelihood: -523.590795742271
#> EM - SNMoE: Iteration: 74 | log-likelihood: -523.587491575797
#> EM - SNMoE: Iteration: 75 | log-likelihood: -523.584233089019
#> EM - SNMoE: Iteration: 76 | log-likelihood: -523.581021883824
#> EM - SNMoE: Iteration: 77 | log-likelihood: -523.577856455209
#> EM - SNMoE: Iteration: 78 | log-likelihood: -523.574730236998
#> EM - SNMoE: Iteration: 79 | log-likelihood: -523.571635200405
#> EM - SNMoE: Iteration: 80 | log-likelihood: -523.568573766492
#> EM - SNMoE: Iteration: 81 | log-likelihood: -523.56554173354
#> EM - SNMoE: Iteration: 82 | log-likelihood: -523.562535677494
#> EM - SNMoE: Iteration: 83 | log-likelihood: -523.559551532338
#> EM - SNMoE: Iteration: 84 | log-likelihood: -523.556578976454
#> EM - SNMoE: Iteration: 85 | log-likelihood: -523.553600421509
#> EM - SNMoE: Iteration: 86 | log-likelihood: -523.550601667654
#> EM - SNMoE: Iteration: 87 | log-likelihood: -523.547582941635
#> EM - SNMoE: Iteration: 88 | log-likelihood: -523.544522897446
#> EM - SNMoE: Iteration: 89 | log-likelihood: -523.541398013478
#> EM - SNMoE: Iteration: 90 | log-likelihood: -523.538203357869
#> EM - SNMoE: Iteration: 91 | log-likelihood: -523.534922687689
#> EM - SNMoE: Iteration: 92 | log-likelihood: -523.531544095041
#> EM - SNMoE: Iteration: 93 | log-likelihood: -523.528027155225
#> EM - SNMoE: Iteration: 94 | log-likelihood: -523.524352514371
#> EM - SNMoE: Iteration: 95 | log-likelihood: -523.520490187566
#> EM - SNMoE: Iteration: 96 | log-likelihood: -523.516420735396
#> EM - SNMoE: Iteration: 97 | log-likelihood: -523.512120694736
#> EM - SNMoE: Iteration: 98 | log-likelihood: -523.507560792466
#> EM - SNMoE: Iteration: 99 | log-likelihood: -523.502724981863
#> EM - SNMoE: Iteration: 100 | log-likelihood: -523.497590807145
#> EM - SNMoE: Iteration: 101 | log-likelihood: -523.492145211405
#> EM - SNMoE: Iteration: 102 | log-likelihood: -523.486378268848
#> EM - SNMoE: Iteration: 103 | log-likelihood: -523.480268583108
#> EM - SNMoE: Iteration: 104 | log-likelihood: -523.473859924045
#> EM - SNMoE: Iteration: 105 | log-likelihood: -523.467172964018
#> EM - SNMoE: Iteration: 106 | log-likelihood: -523.460240119448
#> EM - SNMoE: Iteration: 107 | log-likelihood: -523.45311024469
#> EM - SNMoE: Iteration: 108 | log-likelihood: -523.445844999318
#> EM - SNMoE: Iteration: 109 | log-likelihood: -523.438520442649
#> EM - SNMoE: Iteration: 110 | log-likelihood: -523.43122994192
#> EM - SNMoE: Iteration: 111 | log-likelihood: -523.423950035821
#> EM - SNMoE: Iteration: 112 | log-likelihood: -523.416890389168
#> EM - SNMoE: Iteration: 113 | log-likelihood: -523.410157517294
#> EM - SNMoE: Iteration: 114 | log-likelihood: -523.403846724741
#> EM - SNMoE: Iteration: 115 | log-likelihood: -523.398027731232
#> EM - SNMoE: Iteration: 116 | log-likelihood: -523.392751725313
#> EM - SNMoE: Iteration: 117 | log-likelihood: -523.388042587619
#> EM - SNMoE: Iteration: 118 | log-likelihood: -523.383894385375
#> EM - SNMoE: Iteration: 119 | log-likelihood: -523.380283869845
#> EM - SNMoE: Iteration: 120 | log-likelihood: -523.377180024757
#> EM - SNMoE: Iteration: 121 | log-likelihood: -523.374530445286
#> EM - SNMoE: Iteration: 122 | log-likelihood: -523.372367555717
#> EM - SNMoE: Iteration: 123 | log-likelihood: -523.370543727488
#> EM - SNMoE: Iteration: 124 | log-likelihood: -523.369009015116
#> EM - SNMoE: Iteration: 125 | log-likelihood: -523.367743410373
#> EM - SNMoE: Iteration: 126 | log-likelihood: -523.366705438475
#> EM - SNMoE: Iteration: 127 | log-likelihood: -523.365832842949
#> EM - SNMoE: Iteration: 128 | log-likelihood: -523.365102977721
#> EM - SNMoE: Iteration: 129 | log-likelihood: -523.364492938195
#> EM - SNMoE: Iteration: 130 | log-likelihood: -523.363983216275

snmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-10-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-10-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-10-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-10-4.png" style="display: block; margin: auto;" />

``` r
# Application to a real data set

data("tempanomalies")
x <- tempanomalies$Year
y <- as.matrix(tempanomalies$AnnualAnomaly)

K <- 2 # Number of regressors/experts
p <- 1 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-6
verbose <- TRUE
verbose_IRLS <- FALSE

snmoe <- emSNMoE(X = x, Y = y, K, p, q, n_tries, max_iter, 
                 threshold, verbose, verbose_IRLS)
#> EM - SNMoE: Iteration: 1 | log-likelihood: 77.5588049504538
#> EM - SNMoE: Iteration: 2 | log-likelihood: 87.9745261990751
#> EM - SNMoE: Iteration: 3 | log-likelihood: 88.9083034900161
#> EM - SNMoE: Iteration: 4 | log-likelihood: 89.1598353583341
#> EM - SNMoE: Iteration: 5 | log-likelihood: 89.3723497095182
#> EM - SNMoE: Iteration: 6 | log-likelihood: 89.582158558077
#> EM - SNMoE: Iteration: 7 | log-likelihood: 89.7219214632237
#> EM - SNMoE: Iteration: 8 | log-likelihood: 89.7998543434225
#> EM - SNMoE: Iteration: 9 | log-likelihood: 89.8415579227529
#> EM - SNMoE: Iteration: 10 | log-likelihood: 89.8653487843453
#> EM - SNMoE: Iteration: 11 | log-likelihood: 89.8816619717725
#> EM - SNMoE: Iteration: 12 | log-likelihood: 89.8948755301417
#> EM - SNMoE: Iteration: 13 | log-likelihood: 89.9061666241949
#> EM - SNMoE: Iteration: 14 | log-likelihood: 89.91614332869
#> EM - SNMoE: Iteration: 15 | log-likelihood: 89.9252647516208
#> EM - SNMoE: Iteration: 16 | log-likelihood: 89.9337241330165
#> EM - SNMoE: Iteration: 17 | log-likelihood: 89.9415755277596
#> EM - SNMoE: Iteration: 18 | log-likelihood: 89.9488277337961
#> EM - SNMoE: Iteration: 19 | log-likelihood: 89.9554813598283
#> EM - SNMoE: Iteration: 20 | log-likelihood: 89.9615393159705
#> EM - SNMoE: Iteration: 21 | log-likelihood: 89.967003275662
#> EM - SNMoE: Iteration: 22 | log-likelihood: 89.9720520462384
#> EM - SNMoE: Iteration: 23 | log-likelihood: 89.976550472371
#> EM - SNMoE: Iteration: 24 | log-likelihood: 89.9804681802078
#> EM - SNMoE: Iteration: 25 | log-likelihood: 89.9838292051891
#> EM - SNMoE: Iteration: 26 | log-likelihood: 89.9866429487894
#> EM - SNMoE: Iteration: 27 | log-likelihood: 89.9886476108398
#> EM - SNMoE: Iteration: 28 | log-likelihood: 89.9911032726525
#> EM - SNMoE: Iteration: 29 | log-likelihood: 89.9920454395763
#> EM - SNMoE: Iteration: 30 | log-likelihood: 89.9931148388539
#> EM - SNMoE: Iteration: 31 | log-likelihood: 89.9941020563183
#> EM - SNMoE: Iteration: 32 | log-likelihood: 89.9949082090174
#> EM - SNMoE: Iteration: 33 | log-likelihood: 89.9960342656929
#> EM - SNMoE: Iteration: 34 | log-likelihood: 89.9967724447228
#> EM - SNMoE: Iteration: 35 | log-likelihood: 89.9972981725469
#> EM - SNMoE: Iteration: 36 | log-likelihood: 89.9979752450401
#> EM - SNMoE: Iteration: 37 | log-likelihood: 89.9985716647059
#> EM - SNMoE: Iteration: 38 | log-likelihood: 89.9990664847281
#> EM - SNMoE: Iteration: 39 | log-likelihood: 89.9996735952209
#> EM - SNMoE: Iteration: 40 | log-likelihood: 90.0001946126688
#> EM - SNMoE: Iteration: 41 | log-likelihood: 90.0007108520222
#> EM - SNMoE: Iteration: 42 | log-likelihood: 90.0013081383215
#> EM - SNMoE: Iteration: 43 | log-likelihood: 90.0018424795934
#> EM - SNMoE: Iteration: 44 | log-likelihood: 90.0024303626799
#> EM - SNMoE: Iteration: 45 | log-likelihood: 90.0029955852473
#> EM - SNMoE: Iteration: 46 | log-likelihood: 90.003577523482
#> EM - SNMoE: Iteration: 47 | log-likelihood: 90.0041953457041
#> EM - SNMoE: Iteration: 48 | log-likelihood: 90.0048112553975
#> EM - SNMoE: Iteration: 49 | log-likelihood: 90.0054561373325
#> EM - SNMoE: Iteration: 50 | log-likelihood: 90.0061154272703
#> EM - SNMoE: Iteration: 51 | log-likelihood: 90.0067889721453
#> EM - SNMoE: Iteration: 52 | log-likelihood: 90.0074775673024
#> EM - SNMoE: Iteration: 53 | log-likelihood: 90.0081873884708
#> EM - SNMoE: Iteration: 54 | log-likelihood: 90.008921364198
#> EM - SNMoE: Iteration: 55 | log-likelihood: 90.0096780022315
#> EM - SNMoE: Iteration: 56 | log-likelihood: 90.0104568869128
#> EM - SNMoE: Iteration: 57 | log-likelihood: 90.0112592484168
#> EM - SNMoE: Iteration: 58 | log-likelihood: 90.0120840800077
#> EM - SNMoE: Iteration: 59 | log-likelihood: 90.0129309986077
#> EM - SNMoE: Iteration: 60 | log-likelihood: 90.0138049030624
#> EM - SNMoE: Iteration: 61 | log-likelihood: 90.0147085618207
#> EM - SNMoE: Iteration: 62 | log-likelihood: 90.0156369537266
#> EM - SNMoE: Iteration: 63 | log-likelihood: 90.0165926803699
#> EM - SNMoE: Iteration: 64 | log-likelihood: 90.0175803277436
#> EM - SNMoE: Iteration: 65 | log-likelihood: 90.018597362356
#> EM - SNMoE: Iteration: 66 | log-likelihood: 90.019646804969
#> EM - SNMoE: Iteration: 67 | log-likelihood: 90.0207303782555
#> EM - SNMoE: Iteration: 68 | log-likelihood: 90.0218453834728
#> EM - SNMoE: Iteration: 69 | log-likelihood: 90.0229945452436
#> EM - SNMoE: Iteration: 70 | log-likelihood: 90.0241790025718
#> EM - SNMoE: Iteration: 71 | log-likelihood: 90.0254001719042
#> EM - SNMoE: Iteration: 72 | log-likelihood: 90.026660446196
#> EM - SNMoE: Iteration: 73 | log-likelihood: 90.0279602330292
#> EM - SNMoE: Iteration: 74 | log-likelihood: 90.0292984312465
#> EM - SNMoE: Iteration: 75 | log-likelihood: 90.0306772855044
#> EM - SNMoE: Iteration: 76 | log-likelihood: 90.0320986324761
#> EM - SNMoE: Iteration: 77 | log-likelihood: 90.0335662069804
#> EM - SNMoE: Iteration: 78 | log-likelihood: 90.0350799515003
#> EM - SNMoE: Iteration: 79 | log-likelihood: 90.0366372589094
#> EM - SNMoE: Iteration: 80 | log-likelihood: 90.0382425102671
#> EM - SNMoE: Iteration: 81 | log-likelihood: 90.0398971627963
#> EM - SNMoE: Iteration: 82 | log-likelihood: 90.04160270613
#> EM - SNMoE: Iteration: 83 | log-likelihood: 90.043361949574
#> EM - SNMoE: Iteration: 84 | log-likelihood: 90.0451749257263
#> EM - SNMoE: Iteration: 85 | log-likelihood: 90.0470393202637
#> EM - SNMoE: Iteration: 86 | log-likelihood: 90.0489594702789
#> EM - SNMoE: Iteration: 87 | log-likelihood: 90.0509405555318
#> EM - SNMoE: Iteration: 88 | log-likelihood: 90.0529824729394
#> EM - SNMoE: Iteration: 89 | log-likelihood: 90.0550863665966
#> EM - SNMoE: Iteration: 90 | log-likelihood: 90.0572548865595
#> EM - SNMoE: Iteration: 91 | log-likelihood: 90.0594891713562
#> EM - SNMoE: Iteration: 92 | log-likelihood: 90.0617876573018
#> EM - SNMoE: Iteration: 93 | log-likelihood: 90.0641557232302
#> EM - SNMoE: Iteration: 94 | log-likelihood: 90.0665948317574
#> EM - SNMoE: Iteration: 95 | log-likelihood: 90.0691042405777
#> EM - SNMoE: Iteration: 96 | log-likelihood: 90.0716877288292
#> EM - SNMoE: Iteration: 97 | log-likelihood: 90.074346198305
#> EM - SNMoE: Iteration: 98 | log-likelihood: 90.0770806523619
#> EM - SNMoE: Iteration: 99 | log-likelihood: 90.0798938510858
#> EM - SNMoE: Iteration: 100 | log-likelihood: 90.0827894126518
#> EM - SNMoE: Iteration: 101 | log-likelihood: 90.085767542653
#> EM - SNMoE: Iteration: 102 | log-likelihood: 90.0888274898608
#> EM - SNMoE: Iteration: 103 | log-likelihood: 90.091972426214
#> EM - SNMoE: Iteration: 104 | log-likelihood: 90.0952040117165
#> EM - SNMoE: Iteration: 105 | log-likelihood: 90.0985239288405
#> EM - SNMoE: Iteration: 106 | log-likelihood: 90.1019339096461
#> EM - SNMoE: Iteration: 107 | log-likelihood: 90.1054359926692
#> EM - SNMoE: Iteration: 108 | log-likelihood: 90.1090314580861
#> EM - SNMoE: Iteration: 109 | log-likelihood: 90.1127239108077
#> EM - SNMoE: Iteration: 110 | log-likelihood: 90.1165121531084
#> EM - SNMoE: Iteration: 111 | log-likelihood: 90.1203958284718
#> EM - SNMoE: Iteration: 112 | log-likelihood: 90.1243767456626
#> EM - SNMoE: Iteration: 113 | log-likelihood: 90.1284519353291
#> EM - SNMoE: Iteration: 114 | log-likelihood: 90.1326242257594
#> EM - SNMoE: Iteration: 115 | log-likelihood: 90.1368984028641
#> EM - SNMoE: Iteration: 116 | log-likelihood: 90.1412755775859
#> EM - SNMoE: Iteration: 117 | log-likelihood: 90.1457548232814
#> EM - SNMoE: Iteration: 118 | log-likelihood: 90.1503338470602
#> EM - SNMoE: Iteration: 119 | log-likelihood: 90.1550117897387
#> EM - SNMoE: Iteration: 120 | log-likelihood: 90.1597934834435
#> EM - SNMoE: Iteration: 121 | log-likelihood: 90.1646805204461
#> EM - SNMoE: Iteration: 122 | log-likelihood: 90.1696705128653
#> EM - SNMoE: Iteration: 123 | log-likelihood: 90.1747618040362
#> EM - SNMoE: Iteration: 124 | log-likelihood: 90.1799576286802
#> EM - SNMoE: Iteration: 125 | log-likelihood: 90.185255269538
#> EM - SNMoE: Iteration: 126 | log-likelihood: 90.1906508917006
#> EM - SNMoE: Iteration: 127 | log-likelihood: 90.196144989567
#> EM - SNMoE: Iteration: 128 | log-likelihood: 90.2017369709355
#> EM - SNMoE: Iteration: 129 | log-likelihood: 90.2074192413419
#> EM - SNMoE: Iteration: 130 | log-likelihood: 90.2131981254993
#> EM - SNMoE: Iteration: 131 | log-likelihood: 90.2190735673341
#> EM - SNMoE: Iteration: 132 | log-likelihood: 90.2250384569131
#> EM - SNMoE: Iteration: 133 | log-likelihood: 90.2310940713809
#> EM - SNMoE: Iteration: 134 | log-likelihood: 90.2372363845806
#> EM - SNMoE: Iteration: 135 | log-likelihood: 90.2434648048065
#> EM - SNMoE: Iteration: 136 | log-likelihood: 90.2497741958698
#> EM - SNMoE: Iteration: 137 | log-likelihood: 90.2561589276428
#> EM - SNMoE: Iteration: 138 | log-likelihood: 90.2626223787325
#> EM - SNMoE: Iteration: 139 | log-likelihood: 90.269156607727
#> EM - SNMoE: Iteration: 140 | log-likelihood: 90.2757609824727
#> EM - SNMoE: Iteration: 141 | log-likelihood: 90.2824283086756
#> EM - SNMoE: Iteration: 142 | log-likelihood: 90.2891538213043
#> EM - SNMoE: Iteration: 143 | log-likelihood: 90.2959363616311
#> EM - SNMoE: Iteration: 144 | log-likelihood: 90.3027738924876
#> EM - SNMoE: Iteration: 145 | log-likelihood: 90.3096624397724
#> EM - SNMoE: Iteration: 146 | log-likelihood: 90.3165956048106
#> EM - SNMoE: Iteration: 147 | log-likelihood: 90.3235653058248
#> EM - SNMoE: Iteration: 148 | log-likelihood: 90.3305644808386
#> EM - SNMoE: Iteration: 149 | log-likelihood: 90.3375952084826
#> EM - SNMoE: Iteration: 150 | log-likelihood: 90.3446491376156
#> EM - SNMoE: Iteration: 151 | log-likelihood: 90.3517255731176
#> EM - SNMoE: Iteration: 152 | log-likelihood: 90.3587965696234
#> EM - SNMoE: Iteration: 153 | log-likelihood: 90.3659263882029
#> EM - SNMoE: Iteration: 154 | log-likelihood: 90.373020863225
#> EM - SNMoE: Iteration: 155 | log-likelihood: 90.3801466510873
#> EM - SNMoE: Iteration: 156 | log-likelihood: 90.3872621549379
#> EM - SNMoE: Iteration: 157 | log-likelihood: 90.3943702542233
#> EM - SNMoE: Iteration: 158 | log-likelihood: 90.4014515429062
#> EM - SNMoE: Iteration: 159 | log-likelihood: 90.40852052043
#> EM - SNMoE: Iteration: 160 | log-likelihood: 90.4156019856553
#> EM - SNMoE: Iteration: 161 | log-likelihood: 90.4226660462558
#> EM - SNMoE: Iteration: 162 | log-likelihood: 90.4297433751219
#> EM - SNMoE: Iteration: 163 | log-likelihood: 90.436815073361
#> EM - SNMoE: Iteration: 164 | log-likelihood: 90.4438721649095
#> EM - SNMoE: Iteration: 165 | log-likelihood: 90.4509119371104
#> EM - SNMoE: Iteration: 166 | log-likelihood: 90.4579319965367
#> EM - SNMoE: Iteration: 167 | log-likelihood: 90.4649227107021
#> EM - SNMoE: Iteration: 168 | log-likelihood: 90.4718880504997
#> EM - SNMoE: Iteration: 169 | log-likelihood: 90.4788253432309
#> EM - SNMoE: Iteration: 170 | log-likelihood: 90.4857326096805
#> EM - SNMoE: Iteration: 171 | log-likelihood: 90.4926031099482
#> EM - SNMoE: Iteration: 172 | log-likelihood: 90.4994268532949
#> EM - SNMoE: Iteration: 173 | log-likelihood: 90.5062092171756
#> EM - SNMoE: Iteration: 174 | log-likelihood: 90.5129475281021
#> EM - SNMoE: Iteration: 175 | log-likelihood: 90.5196385208864
#> EM - SNMoE: Iteration: 176 | log-likelihood: 90.5262818932469
#> EM - SNMoE: Iteration: 177 | log-likelihood: 90.532869779391
#> EM - SNMoE: Iteration: 178 | log-likelihood: 90.5394040717856
#> EM - SNMoE: Iteration: 179 | log-likelihood: 90.5458828760447
#> EM - SNMoE: Iteration: 180 | log-likelihood: 90.5523004501508
#> EM - SNMoE: Iteration: 181 | log-likelihood: 90.5586613640295
#> EM - SNMoE: Iteration: 182 | log-likelihood: 90.5649636779653
#> EM - SNMoE: Iteration: 183 | log-likelihood: 90.5712052836669
#> EM - SNMoE: Iteration: 184 | log-likelihood: 90.5773853301012
#> EM - SNMoE: Iteration: 185 | log-likelihood: 90.5835039613534
#> EM - SNMoE: Iteration: 186 | log-likelihood: 90.5895591863673
#> EM - SNMoE: Iteration: 187 | log-likelihood: 90.5955494158556
#> EM - SNMoE: Iteration: 188 | log-likelihood: 90.6014753906761
#> EM - SNMoE: Iteration: 189 | log-likelihood: 90.6073366626089
#> EM - SNMoE: Iteration: 190 | log-likelihood: 90.6131327775258
#> EM - SNMoE: Iteration: 191 | log-likelihood: 90.6188633145306
#> EM - SNMoE: Iteration: 192 | log-likelihood: 90.6245279025959
#> EM - SNMoE: Iteration: 193 | log-likelihood: 90.6301276673822
#> EM - SNMoE: Iteration: 194 | log-likelihood: 90.6356616374185
#> EM - SNMoE: Iteration: 195 | log-likelihood: 90.6411291312945
#> EM - SNMoE: Iteration: 196 | log-likelihood: 90.6465295936079
#> EM - SNMoE: Iteration: 197 | log-likelihood: 90.6518625060788
#> EM - SNMoE: Iteration: 198 | log-likelihood: 90.6571273308022
#> EM - SNMoE: Iteration: 199 | log-likelihood: 90.6623237043397
#> EM - SNMoE: Iteration: 200 | log-likelihood: 90.6674512450832
#> EM - SNMoE: Iteration: 201 | log-likelihood: 90.6725047657649
#> EM - SNMoE: Iteration: 202 | log-likelihood: 90.6774894101896
#> EM - SNMoE: Iteration: 203 | log-likelihood: 90.6824046239363
#> EM - SNMoE: Iteration: 204 | log-likelihood: 90.6872489450495
#> EM - SNMoE: Iteration: 205 | log-likelihood: 90.6920208593367
#> EM - SNMoE: Iteration: 206 | log-likelihood: 90.6967224170873
#> EM - SNMoE: Iteration: 207 | log-likelihood: 90.7013477578695
#> EM - SNMoE: Iteration: 208 | log-likelihood: 90.7058993199993
#> EM - SNMoE: Iteration: 209 | log-likelihood: 90.7103707007143
#> EM - SNMoE: Iteration: 210 | log-likelihood: 90.7147600124963
#> EM - SNMoE: Iteration: 211 | log-likelihood: 90.7190657510712
#> EM - SNMoE: Iteration: 212 | log-likelihood: 90.723286306196
#> EM - SNMoE: Iteration: 213 | log-likelihood: 90.727418687271
#> EM - SNMoE: Iteration: 214 | log-likelihood: 90.7314616105468
#> EM - SNMoE: Iteration: 215 | log-likelihood: 90.7354246245491
#> EM - SNMoE: Iteration: 216 | log-likelihood: 90.7393057329615
#> EM - SNMoE: Iteration: 217 | log-likelihood: 90.7430908168416
#> EM - SNMoE: Iteration: 218 | log-likelihood: 90.7467795632005
#> EM - SNMoE: Iteration: 219 | log-likelihood: 90.7503690014123
#> EM - SNMoE: Iteration: 220 | log-likelihood: 90.7538573574483
#> EM - SNMoE: Iteration: 221 | log-likelihood: 90.7573155184951
#> EM - SNMoE: Iteration: 222 | log-likelihood: 90.76040748094
#> EM - SNMoE: Iteration: 223 | log-likelihood: 90.7637231924066
#> EM - SNMoE: Iteration: 224 | log-likelihood: 90.7666487303288
#> EM - SNMoE: Iteration: 225 | log-likelihood: 90.7695403495196
#> EM - SNMoE: Iteration: 226 | log-likelihood: 90.7723379769783
#> EM - SNMoE: Iteration: 227 | log-likelihood: 90.7750843577595
#> EM - SNMoE: Iteration: 228 | log-likelihood: 90.7776924360328
#> EM - SNMoE: Iteration: 229 | log-likelihood: 90.7802339441228
#> EM - SNMoE: Iteration: 230 | log-likelihood: 90.7826740845081
#> EM - SNMoE: Iteration: 231 | log-likelihood: 90.7850276020966
#> EM - SNMoE: Iteration: 232 | log-likelihood: 90.7872856859716
#> EM - SNMoE: Iteration: 233 | log-likelihood: 90.7894629254612
#> EM - SNMoE: Iteration: 234 | log-likelihood: 90.7915603576729
#> EM - SNMoE: Iteration: 235 | log-likelihood: 90.7937299017339
#> EM - SNMoE: Iteration: 236 | log-likelihood: 90.7956951632693
#> EM - SNMoE: Iteration: 237 | log-likelihood: 90.7975396296803
#> EM - SNMoE: Iteration: 238 | log-likelihood: 90.7993342832208
#> EM - SNMoE: Iteration: 239 | log-likelihood: 90.801034724351
#> EM - SNMoE: Iteration: 240 | log-likelihood: 90.8026785985547
#> EM - SNMoE: Iteration: 241 | log-likelihood: 90.8042523204305
#> EM - SNMoE: Iteration: 242 | log-likelihood: 90.8057552724083
#> EM - SNMoE: Iteration: 243 | log-likelihood: 90.8071928685402
#> EM - SNMoE: Iteration: 244 | log-likelihood: 90.8085701970242
#> EM - SNMoE: Iteration: 245 | log-likelihood: 90.8098890857868
#> EM - SNMoE: Iteration: 246 | log-likelihood: 90.8111513623643
#> EM - SNMoE: Iteration: 247 | log-likelihood: 90.8123588404294
#> EM - SNMoE: Iteration: 248 | log-likelihood: 90.813625219557
#> EM - SNMoE: Iteration: 249 | log-likelihood: 90.8147224191899
#> EM - SNMoE: Iteration: 250 | log-likelihood: 90.8157706939414
#> EM - SNMoE: Iteration: 251 | log-likelihood: 90.8167717743941
#> EM - SNMoE: Iteration: 252 | log-likelihood: 90.817727413416
#> EM - SNMoE: Iteration: 253 | log-likelihood: 90.8186552261459
#> EM - SNMoE: Iteration: 254 | log-likelihood: 90.8195239940828
#> EM - SNMoE: Iteration: 255 | log-likelihood: 90.8203524454762
#> EM - SNMoE: Iteration: 256 | log-likelihood: 90.8211503434003
#> EM - SNMoE: Iteration: 257 | log-likelihood: 90.8219065069068
#> EM - SNMoE: Iteration: 258 | log-likelihood: 90.8226268542505
#> EM - SNMoE: Iteration: 259 | log-likelihood: 90.8233087019395
#> EM - SNMoE: Iteration: 260 | log-likelihood: 90.8239579066592
#> EM - SNMoE: Iteration: 261 | log-likelihood: 90.8245758494489
#> EM - SNMoE: Iteration: 262 | log-likelihood: 90.8251639514503
#> EM - SNMoE: Iteration: 263 | log-likelihood: 90.8257238139914
#> EM - SNMoE: Iteration: 264 | log-likelihood: 90.8262566849161
#> EM - SNMoE: Iteration: 265 | log-likelihood: 90.8268265418074
#> EM - SNMoE: Iteration: 266 | log-likelihood: 90.8273071139977
#> EM - SNMoE: Iteration: 267 | log-likelihood: 90.8277005463579
#> EM - SNMoE: Iteration: 268 | log-likelihood: 90.8282073797767
#> EM - SNMoE: Iteration: 269 | log-likelihood: 90.8286069034142
#> EM - SNMoE: Iteration: 270 | log-likelihood: 90.8289957124863
#> EM - SNMoE: Iteration: 271 | log-likelihood: 90.829374711956
#> EM - SNMoE: Iteration: 272 | log-likelihood: 90.829724933715
#> EM - SNMoE: Iteration: 273 | log-likelihood: 90.8300573725256
#> EM - SNMoE: Iteration: 274 | log-likelihood: 90.8303827461606
#> EM - SNMoE: Iteration: 275 | log-likelihood: 90.8306818137973
#> EM - SNMoE: Iteration: 276 | log-likelihood: 90.8309655619124
#> EM - SNMoE: Iteration: 277 | log-likelihood: 90.8312347269134
#> EM - SNMoE: Iteration: 278 | log-likelihood: 90.831490018286
#> EM - SNMoE: Iteration: 279 | log-likelihood: 90.8317321135387
#> EM - SNMoE: Iteration: 280 | log-likelihood: 90.8319616591422
#> EM - SNMoE: Iteration: 281 | log-likelihood: 90.8321792716335
#> EM - SNMoE: Iteration: 282 | log-likelihood: 90.8323855387237
#> EM - SNMoE: Iteration: 283 | log-likelihood: 90.8325809742831
#> EM - SNMoE: Iteration: 284 | log-likelihood: 90.8327661573165
#> EM - SNMoE: Iteration: 285 | log-likelihood: 90.8329416778216
#> EM - SNMoE: Iteration: 286 | log-likelihood: 90.8331522350455
#> EM - SNMoE: Iteration: 287 | log-likelihood: 90.8333090301275
#> EM - SNMoE: Iteration: 288 | log-likelihood: 90.8334129117
#> EM - SNMoE: Iteration: 289 | log-likelihood: 90.8335988568264
#> EM - SNMoE: Iteration: 290 | log-likelihood: 90.8337319658443
#> EM - SNMoE: Iteration: 291 | log-likelihood: 90.8338131199142

snmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-11-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-11-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-11-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-11-4.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>StMoE</summary>

``` r
# Applicartion to a simulated data set

n <- 500 # Size of the sample
alphak <- matrix(c(0, 8), ncol = 1) # Parameters of the gating network
betak <- matrix(c(0, -2.5, 0, 2.5), ncol = 2) # Regression coefficients of the experts
sigmak <- c(0.5, 0.5) # Standard deviations of the experts
lambdak <- c(3, 5) # Skewness parameters of the experts
nuk <- c(5, 7) # Degrees of freedom of the experts network t densities
x <- seq.int(from = -1, to = 1, length.out = n) # Inputs (predictors)

# Generate sample of size n
sample <- sampleUnivSTMoE(alphak = alphak, betak = betak, sigmak = sigmak, 
                          lambdak = lambdak, nuk = nuk, x = x)
y <- matrix(sample$y)

K <- 2 # Number of regressors/experts
p <- 1 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

stmoe <- emStMoE(X = x, Y = y, K, p, q, n_tries, max_iter, 
                 threshold, verbose, verbose_IRLS)
#> EM - StMoE: Iteration: 1 | log-likelihood: -421.718778124984
#> EM - StMoE: Iteration: 2 | log-likelihood: -387.398018429482
#> EM - StMoE: Iteration: 3 | log-likelihood: -371.647654764117
#> EM - StMoE: Iteration: 4 | log-likelihood: -366.461229718449
#> EM - StMoE: Iteration: 5 | log-likelihood: -363.356471719056
#> EM - StMoE: Iteration: 6 | log-likelihood: -361.490125256114
#> EM - StMoE: Iteration: 7 | log-likelihood: -360.276109349998
#> EM - StMoE: Iteration: 8 | log-likelihood: -359.3785844562
#> EM - StMoE: Iteration: 9 | log-likelihood: -358.608567063339
#> EM - StMoE: Iteration: 10 | log-likelihood: -357.853737852936
#> EM - StMoE: Iteration: 11 | log-likelihood: -357.0370168046
#> EM - StMoE: Iteration: 12 | log-likelihood: -356.094673991505
#> EM - StMoE: Iteration: 13 | log-likelihood: -354.971550009591
#> EM - StMoE: Iteration: 14 | log-likelihood: -353.621846363898
#> EM - StMoE: Iteration: 15 | log-likelihood: -352.017396616314
#> EM - StMoE: Iteration: 16 | log-likelihood: -350.162748949399
#> EM - StMoE: Iteration: 17 | log-likelihood: -348.077371903025
#> EM - StMoE: Iteration: 18 | log-likelihood: -345.784024088348
#> EM - StMoE: Iteration: 19 | log-likelihood: -343.295284300523
#> EM - StMoE: Iteration: 20 | log-likelihood: -340.613642278264
#> EM - StMoE: Iteration: 21 | log-likelihood: -337.732002104567
#> EM - StMoE: Iteration: 22 | log-likelihood: -334.615700907785
#> EM - StMoE: Iteration: 23 | log-likelihood: -331.182546598332
#> EM - StMoE: Iteration: 24 | log-likelihood: -327.270075382575
#> EM - StMoE: Iteration: 25 | log-likelihood: -322.657942781536
#> EM - StMoE: Iteration: 26 | log-likelihood: -317.195630795251
#> EM - StMoE: Iteration: 27 | log-likelihood: -310.990068343662
#> EM - StMoE: Iteration: 28 | log-likelihood: -304.445345005765
#> EM - StMoE: Iteration: 29 | log-likelihood: -298.048589261673
#> EM - StMoE: Iteration: 30 | log-likelihood: -292.136524946117
#> EM - StMoE: Iteration: 31 | log-likelihood: -286.874700218437
#> EM - StMoE: Iteration: 32 | log-likelihood: -282.308995027937
#> EM - StMoE: Iteration: 33 | log-likelihood: -278.410097415242
#> EM - StMoE: Iteration: 34 | log-likelihood: -275.113323072852
#> EM - StMoE: Iteration: 35 | log-likelihood: -272.339545922037
#> EM - StMoE: Iteration: 36 | log-likelihood: -270.013040313725
#> EM - StMoE: Iteration: 37 | log-likelihood: -268.056719012855
#> EM - StMoE: Iteration: 38 | log-likelihood: -266.410692136639
#> EM - StMoE: Iteration: 39 | log-likelihood: -265.019016820677
#> EM - StMoE: Iteration: 40 | log-likelihood: -263.835208203873
#> EM - StMoE: Iteration: 41 | log-likelihood: -262.822535514192
#> EM - StMoE: Iteration: 42 | log-likelihood: -261.951975853009
#> EM - StMoE: Iteration: 43 | log-likelihood: -261.199617672704
#> EM - StMoE: Iteration: 44 | log-likelihood: -260.546661111959
#> EM - StMoE: Iteration: 45 | log-likelihood: -259.97686877111
#> EM - StMoE: Iteration: 46 | log-likelihood: -259.477550322628
#> EM - StMoE: Iteration: 47 | log-likelihood: -259.038383202812
#> EM - StMoE: Iteration: 48 | log-likelihood: -258.650926312456
#> EM - StMoE: Iteration: 49 | log-likelihood: -258.308510438767
#> EM - StMoE: Iteration: 50 | log-likelihood: -258.004631030576
#> EM - StMoE: Iteration: 51 | log-likelihood: -257.734554460298
#> EM - StMoE: Iteration: 52 | log-likelihood: -257.49380668731
#> EM - StMoE: Iteration: 53 | log-likelihood: -257.278356124513
#> EM - StMoE: Iteration: 54 | log-likelihood: -257.085036522986
#> EM - StMoE: Iteration: 55 | log-likelihood: -256.911020960875
#> EM - StMoE: Iteration: 56 | log-likelihood: -256.753952570638
#> EM - StMoE: Iteration: 57 | log-likelihood: -256.611933410643
#> EM - StMoE: Iteration: 58 | log-likelihood: -256.483597673984
#> EM - StMoE: Iteration: 59 | log-likelihood: -256.367302254376
#> EM - StMoE: Iteration: 60 | log-likelihood: -256.261644410341
#> EM - StMoE: Iteration: 61 | log-likelihood: -256.165476365154
#> EM - StMoE: Iteration: 62 | log-likelihood: -256.077681649427
#> EM - StMoE: Iteration: 63 | log-likelihood: -255.997383364522
#> EM - StMoE: Iteration: 64 | log-likelihood: -255.923797405391
#> EM - StMoE: Iteration: 65 | log-likelihood: -255.856237174526
#> EM - StMoE: Iteration: 66 | log-likelihood: -255.79427126809
#> EM - StMoE: Iteration: 67 | log-likelihood: -255.737487862981
#> EM - StMoE: Iteration: 68 | log-likelihood: -255.685454148413
#> EM - StMoE: Iteration: 69 | log-likelihood: -255.637693094412
#> EM - StMoE: Iteration: 70 | log-likelihood: -255.59378567304
#> EM - StMoE: Iteration: 71 | log-likelihood: -255.553362630851
#> EM - StMoE: Iteration: 72 | log-likelihood: -255.516161754916
#> EM - StMoE: Iteration: 73 | log-likelihood: -255.481820366976
#> EM - StMoE: Iteration: 74 | log-likelihood: -255.45008298488
#> EM - StMoE: Iteration: 75 | log-likelihood: -255.420721824098
#> EM - StMoE: Iteration: 76 | log-likelihood: -255.393518261678
#> EM - StMoE: Iteration: 77 | log-likelihood: -255.368310586169
#> EM - StMoE: Iteration: 78 | log-likelihood: -255.344933498359
#> EM - StMoE: Iteration: 79 | log-likelihood: -255.323203453081
#> EM - StMoE: Iteration: 80 | log-likelihood: -255.303024483709
#> EM - StMoE: Iteration: 81 | log-likelihood: -255.284272661668
#> EM - StMoE: Iteration: 82 | log-likelihood: -255.266834525664
#> EM - StMoE: Iteration: 83 | log-likelihood: -255.250605611999
#> EM - StMoE: Iteration: 84 | log-likelihood: -255.235487107387
#> EM - StMoE: Iteration: 85 | log-likelihood: -255.221387533897
#> EM - StMoE: Iteration: 86 | log-likelihood: -255.208222391443
#> EM - StMoE: Iteration: 87 | log-likelihood: -255.195911537253
#> EM - StMoE: Iteration: 88 | log-likelihood: -255.184378270662
#> EM - StMoE: Iteration: 89 | log-likelihood: -255.173549077791
#> EM - StMoE: Iteration: 90 | log-likelihood: -255.163353663609
#> EM - StMoE: Iteration: 91 | log-likelihood: -255.153726196421
#> EM - StMoE: Iteration: 92 | log-likelihood: -255.144602854037
#> EM - StMoE: Iteration: 93 | log-likelihood: -255.135912580362
#> EM - StMoE: Iteration: 94 | log-likelihood: -255.127591437371
#> EM - StMoE: Iteration: 95 | log-likelihood: -255.119606757399
#> EM - StMoE: Iteration: 96 | log-likelihood: -255.111868574952
#> EM - StMoE: Iteration: 97 | log-likelihood: -255.104309491706
#> EM - StMoE: Iteration: 98 | log-likelihood: -255.096861591383
#> EM - StMoE: Iteration: 99 | log-likelihood: -255.089456856106
#> EM - StMoE: Iteration: 100 | log-likelihood: -255.082027917213
#> EM - StMoE: Iteration: 101 | log-likelihood: -255.074509188311
#> EM - StMoE: Iteration: 102 | log-likelihood: -255.066838373527
#> EM - StMoE: Iteration: 103 | log-likelihood: -255.058997532797
#> EM - StMoE: Iteration: 104 | log-likelihood: -255.050974095787
#> EM - StMoE: Iteration: 105 | log-likelihood: -255.042717236492
#> EM - StMoE: Iteration: 106 | log-likelihood: -255.034189721522
#> EM - StMoE: Iteration: 107 | log-likelihood: -255.025369569073
#> EM - StMoE: Iteration: 108 | log-likelihood: -255.016250904527
#> EM - StMoE: Iteration: 109 | log-likelihood: -255.006843654226
#> EM - StMoE: Iteration: 110 | log-likelihood: -254.9971718216
#> EM - StMoE: Iteration: 111 | log-likelihood: -254.987270276586
#> EM - StMoE: Iteration: 112 | log-likelihood: -254.977180232361
#> EM - StMoE: Iteration: 113 | log-likelihood: -254.966943834321
#> EM - StMoE: Iteration: 114 | log-likelihood: -254.956598492689
#> EM - StMoE: Iteration: 115 | log-likelihood: -254.94617171133
#> EM - StMoE: Iteration: 116 | log-likelihood: -254.935677179494
#> EM - StMoE: Iteration: 117 | log-likelihood: -254.925112794025
#> EM - StMoE: Iteration: 118 | log-likelihood: -254.914461073038
#> EM - StMoE: Iteration: 119 | log-likelihood: -254.903692123252
#> EM - StMoE: Iteration: 120 | log-likelihood: -254.892768955152
#> EM - StMoE: Iteration: 121 | log-likelihood: -254.881654535768
#> EM - StMoE: Iteration: 122 | log-likelihood: -254.870319579725
#> EM - StMoE: Iteration: 123 | log-likelihood: -254.858749790618
#> EM - StMoE: Iteration: 124 | log-likelihood: -254.846951198969
#> EM - StMoE: Iteration: 125 | log-likelihood: -254.834952526659
#> EM - StMoE: Iteration: 126 | log-likelihood: -254.822804195119
#> EM - StMoE: Iteration: 127 | log-likelihood: -254.810574579951
#> EM - StMoE: Iteration: 128 | log-likelihood: -254.798345103594
#> EM - StMoE: Iteration: 129 | log-likelihood: -254.786206337508
#> EM - StMoE: Iteration: 130 | log-likelihood: -254.774257041821
#> EM - StMoE: Iteration: 131 | log-likelihood: -254.762606676395
#> EM - StMoE: Iteration: 132 | log-likelihood: -254.751379354261
#> EM - StMoE: Iteration: 133 | log-likelihood: -254.740714445978
#> EM - StMoE: Iteration: 134 | log-likelihood: -254.730758618274
#> EM - StMoE: Iteration: 135 | log-likelihood: -254.721648342227
#> EM - StMoE: Iteration: 136 | log-likelihood: -254.71348881173
#> EM - StMoE: Iteration: 137 | log-likelihood: -254.706338456478
#> EM - StMoE: Iteration: 138 | log-likelihood: -254.70020466137
#> EM - StMoE: Iteration: 139 | log-likelihood: -254.695049919416
#> EM - StMoE: Iteration: 140 | log-likelihood: -254.690803815926
#> EM - StMoE: Iteration: 141 | log-likelihood: -254.68737449209
#> EM - StMoE: Iteration: 142 | log-likelihood: -254.684665482918
#> EM - StMoE: Iteration: 143 | log-likelihood: -254.682568532504

stmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-12-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-12-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-12-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-12-4.png" style="display: block; margin: auto;" />

``` r
# Applicartion to a real data set

library(MASS)
data("mcycle")
x <- mcycle$times
y <- as.matrix(mcycle$accel)

K <- 4 # Number of regressors/experts
p <- 2 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

stmoe <- emStMoE(X = x, Y = y, K, p, q, n_tries, max_iter, 
                 threshold, verbose, verbose_IRLS)
#> EM - StMoE: Iteration: 1 | log-likelihood: -599.260556013022
#> EM - StMoE: Iteration: 2 | log-likelihood: -582.737266750789
#> EM - StMoE: Iteration: 3 | log-likelihood: -580.910448600809
#> EM - StMoE: Iteration: 4 | log-likelihood: -579.350952128335
#> EM - StMoE: Iteration: 5 | log-likelihood: -577.562917232936
#> EM - StMoE: Iteration: 6 | log-likelihood: -574.8489175922
#> EM - StMoE: Iteration: 7 | log-likelihood: -568.636555144273
#> EM - StMoE: Iteration: 8 | log-likelihood: -563.15931510811
#> EM - StMoE: Iteration: 9 | log-likelihood: -559.660262515703
#> EM - StMoE: Iteration: 10 | log-likelihood: -557.735339182376
#> EM - StMoE: Iteration: 11 | log-likelihood: -556.406470405942
#> EM - StMoE: Iteration: 12 | log-likelihood: -555.324629653951
#> EM - StMoE: Iteration: 13 | log-likelihood: -554.495092243812
#> EM - StMoE: Iteration: 14 | log-likelihood: -553.93708756244
#> EM - StMoE: Iteration: 15 | log-likelihood: -553.605314451086
#> EM - StMoE: Iteration: 16 | log-likelihood: -553.424560036231
#> EM - StMoE: Iteration: 17 | log-likelihood: -553.330505620054
#> EM - StMoE: Iteration: 18 | log-likelihood: -553.285594407713
#> EM - StMoE: Iteration: 19 | log-likelihood: -553.269782646306
#> EM - StMoE: Iteration: 20 | log-likelihood: -553.272042358307

stmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-13-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-13-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-13-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-13-4.png" style="display: block; margin: auto;" />

</details>

# References

<div id="refs" class="references">

<div id="ref-Chamroukhi-STMoE-2017">

Chamroukhi, F. 2017. “Skew-T Mixture of Experts.” *Neurocomputing -
Elsevier* 266: 390–408. <https://chamroukhi.com/papers/STMoE.pdf>.

</div>

<div id="ref-Chamroukhi-TMoE-2016">

Chamroukhi, F. 2016a. “Robust Mixture of Experts Modeling Using the
T-Distribution.” *Neural Networks - Elsevier* 79: 20–36.
<https://chamroukhi.com/papers/TMoE.pdf>.

</div>

<div id="ref-Chamroukhi-SNMoE-IJCNN-2016">

Chamroukhi, F. 2016b. “Skew-Normal Mixture of Experts.” In *The
International Joint Conference on Neural Networks (IJCNN)*. Vancouver,
Canada. <https://chamroukhi.com/papers/Chamroukhi-SNMoE-IJCNN2016.pdf>.

</div>

<div id="ref-Chamroukhi-NNMoE-2015">

Chamroukhi, F. 2015a. “Non-Normal Mixtures of Experts.”
<http://arxiv.org/pdf/1506.06707.pdf>.

</div>

<div id="ref-Chamroukhi-HDR-2015">

Chamroukhi, F. 2015b. “Statistical Learning of Latent Data Models for
Complex Data Analysis.” Habilitation Thesis (HDR), Université de Toulon.
<https://chamroukhi.com/FChamroukhi-HDR.pdf>.

</div>

<div id="ref-Chamroukhi_PhD_2010">

Chamroukhi, F. 2010. “Hidden Process Regression for Curve Modeling,
Classification and Tracking.” Ph.D. Thesis, Université de Technologie de
Compiègne. <https://chamroukhi.com/FChamroukhi-PhD.pdf>.

</div>

<div id="ref-chamroukhi_et_al_NN2009">

Chamroukhi, F., A. Samé, G. Govaert, and P. Aknin. 2009. “Time Series
Modeling by a Regression Approach Based on a Latent Process.” *Neural
Networks* 22 (5-6): 593–602.
<https://chamroukhi.com/papers/Chamroukhi_Neural_Networks_2009.pdf>.

</div>

</div>
