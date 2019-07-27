
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
  - NNMoE;
  - tMoE;
  - StMoE;
  - SNMoE;
  - RMoE.

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
# (fyi: NMoE is for  the standard normal mixture-of-experts model)

n <- 500 # Size of the sample
K <- 2 # Number of regressors/experts
p <- 1 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

alphak <- matrix(c(0, 8), ncol = K - 1) # Parameters of the gating network
betak <- matrix(c(0, -2.5, 0, 2.5), ncol = K) # Regression coefficients of the experts
sigmak <- c(1, 1) # Standard deviations of the experts
x <- seq.int(from = -1, to = 1, length.out = n) # Inputs (predictors)

# Generate sample of size n
sample <- sampleUnivNMoE(alphak = alphak, betak = betak, sigmak = sigmak, x = x)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

nmoe <- emNMoE(x, matrix(sample$y), K, p, q, n_tries, max_iter, 
               threshold, verbose, verbose_IRLS)
#> EM: Iteration: 1 || log-likelihood: -903.534650314522
#> EM: Iteration: 2 || log-likelihood: -731.733400738692
#> EM: Iteration: 3 || log-likelihood: -727.761470730678
#> EM: Iteration: 4 || log-likelihood: -725.724853271017
#> EM: Iteration: 5 || log-likelihood: -724.614729450554
#> EM: Iteration: 6 || log-likelihood: -723.972464804324
#> EM: Iteration: 7 || log-likelihood: -723.579795235583
#> EM: Iteration: 8 || log-likelihood: -723.328270834418
#> EM: Iteration: 9 || log-likelihood: -723.161308526573
#> EM: Iteration: 10 || log-likelihood: -723.04772750504
#> EM: Iteration: 11 || log-likelihood: -722.969295782552
#> EM: Iteration: 12 || log-likelihood: -722.914711053563
#> EM: Iteration: 13 || log-likelihood: -722.876604643242
#> EM: Iteration: 14 || log-likelihood: -722.84999448677
#> EM: Iteration: 15 || log-likelihood: -722.831433747617
#> EM: Iteration: 16 || log-likelihood: -722.818509864875
#> EM: Iteration: 17 || log-likelihood: -722.80952711246
#> EM: Iteration: 18 || log-likelihood: -722.803293690611

nmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-6-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-4.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>TMoE</summary>

``` r

n <- 500 # Size of the sample
K <- 2 # Number of regressors/experts
p <- 1 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

alphak <- matrix(c(0, 8), ncol = K - 1) # Parameters of the gating network
betak <- matrix(c(0, -2.5, 0, 2.5), ncol = K) # Regression coefficients of the experts
sigmak <- c(0.5, 0.5) # Standard deviations of the experts
nuk <- c(7, 9) # Degrees of freedom of the experts network t densities
x <- seq.int(from = -1, to = 1, length.out = n) # Inputs (predictors)

# Generate sample of size n
sample <- sampleUnivTMoE(alphak = alphak, betak = betak, sigmak = sigmak, 
                         nuk = nuk, x = x)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

tmoe <- emTMoE(x, matrix(sample$y), K, p, q, n_tries, max_iter, 
               threshold, verbose, verbose_IRLS)
#> EM: Iteration: 1 || log-likelihood: -677.753017331372
#> EM: Iteration: 2 || log-likelihood: -434.664548475192
#> EM: Iteration: 3 || log-likelihood: -431.986438393336
#> EM: Iteration: 4 || log-likelihood: -431.539481072099
#> EM: Iteration: 5 || log-likelihood: -431.440787941356
#> EM: Iteration: 6 || log-likelihood: -431.402655949294
#> EM: Iteration: 7 || log-likelihood: -431.376207232259
#> EM: Iteration: 8 || log-likelihood: -431.352152664073
#> EM: Iteration: 9 || log-likelihood: -431.328561428721
#> EM: Iteration: 10 || log-likelihood: -431.304999715712
#> EM: Iteration: 11 || log-likelihood: -431.281363476225
#> EM: Iteration: 12 || log-likelihood: -431.257628763256
#> EM: Iteration: 13 || log-likelihood: -431.233793799679
#> EM: Iteration: 14 || log-likelihood: -431.209864005472
#> EM: Iteration: 15 || log-likelihood: -431.185847575183
#> EM: Iteration: 16 || log-likelihood: -431.161754005839
#> EM: Iteration: 17 || log-likelihood: -431.137593556907
#> EM: Iteration: 18 || log-likelihood: -431.113377039672
#> EM: Iteration: 19 || log-likelihood: -431.089115730644
#> EM: Iteration: 20 || log-likelihood: -431.064821332416
#> EM: Iteration: 21 || log-likelihood: -431.040505951879
#> EM: Iteration: 22 || log-likelihood: -431.016182083688
#> EM: Iteration: 23 || log-likelihood: -430.991862594105
#> EM: Iteration: 24 || log-likelihood: -430.967560703284
#> EM: Iteration: 25 || log-likelihood: -430.943289965292
#> EM: Iteration: 26 || log-likelihood: -430.919064245576
#> EM: Iteration: 27 || log-likelihood: -430.894897695844
#> EM: Iteration: 28 || log-likelihood: -430.87080472637
#> EM: Iteration: 29 || log-likelihood: -430.846799975767
#> EM: Iteration: 30 || log-likelihood: -430.822898278311
#> EM: Iteration: 31 || log-likelihood: -430.799114628908
#> EM: Iteration: 32 || log-likelihood: -430.775464145804
#> EM: Iteration: 33 || log-likelihood: -430.751962031174
#> EM: Iteration: 34 || log-likelihood: -430.728623529756
#> EM: Iteration: 35 || log-likelihood: -430.705463885695
#> EM: Iteration: 36 || log-likelihood: -430.682498297791
#> EM: Iteration: 37 || log-likelihood: -430.659741873394
#> EM: Iteration: 38 || log-likelihood: -430.637209581184
#> EM: Iteration: 39 || log-likelihood: -430.614916203103
#> EM: Iteration: 40 || log-likelihood: -430.592876285732
#> EM: Iteration: 41 || log-likelihood: -430.57110409143
#> EM: Iteration: 42 || log-likelihood: -430.549613549526
#> EM: Iteration: 43 || log-likelihood: -430.528418207952
#> EM: Iteration: 44 || log-likelihood: -430.507531185601
#> EM: Iteration: 45 || log-likelihood: -430.486965125808
#> EM: Iteration: 46 || log-likelihood: -430.466732151278
#> EM: Iteration: 47 || log-likelihood: -430.446843820813
#> EM: Iteration: 48 || log-likelihood: -430.427311088191
#> EM: Iteration: 49 || log-likelihood: -430.408144263506
#> EM: Iteration: 50 || log-likelihood: -430.389352977295
#> EM: Iteration: 51 || log-likelihood: -430.37094614775
#> EM: Iteration: 52 || log-likelihood: -430.352931951272
#> EM: Iteration: 53 || log-likelihood: -430.335317796606
#> EM: Iteration: 54 || log-likelihood: -430.318110302792
#> EM: Iteration: 55 || log-likelihood: -430.301315281074
#> EM: Iteration: 56 || log-likelihood: -430.284937720932
#> EM: Iteration: 57 || log-likelihood: -430.268981780318
#> EM: Iteration: 58 || log-likelihood: -430.253450780187
#> EM: Iteration: 59 || log-likelihood: -430.238347203289
#> EM: Iteration: 60 || log-likelihood: -430.223672697262
#> EM: Iteration: 61 || log-likelihood: -430.209428081915
#> EM: Iteration: 62 || log-likelihood: -430.195613360621
#> EM: Iteration: 63 || log-likelihood: -430.182227735674
#> EM: Iteration: 64 || log-likelihood: -430.169269627444
#> EM: Iteration: 65 || log-likelihood: -430.15673669709
#> EM: Iteration: 66 || log-likelihood: -430.144625872636
#> EM: Iteration: 67 || log-likelihood: -430.132933378106
#> EM: Iteration: 68 || log-likelihood: -430.121654765449
#> EM: Iteration: 69 || log-likelihood: -430.110784948957
#> EM: Iteration: 70 || log-likelihood: -430.100318241816
#> EM: Iteration: 71 || log-likelihood: -430.090248394522
#> EM: Iteration: 72 || log-likelihood: -430.080568634763
#> EM: Iteration: 73 || log-likelihood: -430.071271708481
#> EM: Iteration: 74 || log-likelihood: -430.06234992175
#> EM: Iteration: 75 || log-likelihood: -430.053795183159
#> EM: Iteration: 76 || log-likelihood: -430.045599046376
#> EM: Iteration: 77 || log-likelihood: -430.037752752592
#> EM: Iteration: 78 || log-likelihood: -430.030247272568
#> EM: Iteration: 79 || log-likelihood: -430.023073347997
#> EM: Iteration: 80 || log-likelihood: -430.016221531957
#> EM: Iteration: 81 || log-likelihood: -430.009682228211
#> EM: Iteration: 82 || log-likelihood: -430.003445729165
#> EM: Iteration: 83 || log-likelihood: -429.997502252309
#> EM: Iteration: 84 || log-likelihood: -429.991841974971
#> EM: Iteration: 85 || log-likelihood: -429.986455067279
#> EM: Iteration: 86 || log-likelihood: -429.981331723211
#> EM: Iteration: 87 || log-likelihood: -429.976462189666
#> EM: Iteration: 88 || log-likelihood: -429.971836793482
#> EM: Iteration: 89 || log-likelihood: -429.967445966389
#> EM: Iteration: 90 || log-likelihood: -429.963280267853

tmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-7-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-4.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>SNMoE</summary>

``` r

n <- 500 # Size of the sample
K <- 2 # Number of regressors/experts
p <- 1 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

alphak <- matrix(c(0, 8), ncol = K - 1) # Parameters of the gating network
betak <- matrix(c(0, -2.5, 0, 2.5), ncol = K) # Regression coefficients of the experts
lambdak <- c(3, 5) # Skewness parameters of the experts
sigmak <- c(1, 1) # Standard deviations of the experts
x <- seq.int(from = -1, to = 1, length.out = n) # Inputs (predictors)

# Generate sample of size n
sample <- sampleUnivSNMoE(alphak = alphak, betak = betak, sigmak = sigmak, 
                          lambdak = lambdak, x = x)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-6
verbose <- TRUE
verbose_IRLS <- FALSE

snmoe <- emSNMoE(x, matrix(sample$y), K, p, q, n_tries, max_iter, 
                 threshold, verbose, verbose_IRLS)
#> EM: Iteration: 1 || log-likelihood: -704.382809718028
#> EM: Iteration: 2 || log-likelihood: -492.870169625157
#> EM: Iteration: 3 || log-likelihood: -486.097997678643
#> EM: Iteration: 4 || log-likelihood: -484.123522954038
#> EM: Iteration: 5 || log-likelihood: -483.531698427995
#> EM: Iteration: 6 || log-likelihood: -483.330321779677
#> EM: Iteration: 7 || log-likelihood: -483.249249739328
#> EM: Iteration: 8 || log-likelihood: -483.21079087566
#> EM: Iteration: 9 || log-likelihood: -483.189773247224
#> EM: Iteration: 10 || log-likelihood: -483.176809216954
#> EM: Iteration: 11 || log-likelihood: -483.167915220457
#> EM: Iteration: 12 || log-likelihood: -483.161224833515
#> EM: Iteration: 13 || log-likelihood: -483.155788303012
#> EM: Iteration: 14 || log-likelihood: -483.151112311417
#> EM: Iteration: 15 || log-likelihood: -483.146948853097
#> EM: Iteration: 16 || log-likelihood: -483.143147207793
#> EM: Iteration: 17 || log-likelihood: -483.139617924821
#> EM: Iteration: 18 || log-likelihood: -483.1363068011
#> EM: Iteration: 19 || log-likelihood: -483.133176768727
#> EM: Iteration: 20 || log-likelihood: -483.130197593424
#> EM: Iteration: 21 || log-likelihood: -483.127363256507
#> EM: Iteration: 22 || log-likelihood: -483.124659815004
#> EM: Iteration: 23 || log-likelihood: -483.122066482053
#> EM: Iteration: 24 || log-likelihood: -483.119581630388
#> EM: Iteration: 25 || log-likelihood: -483.117198361979
#> EM: Iteration: 26 || log-likelihood: -483.114910696027
#> EM: Iteration: 27 || log-likelihood: -483.112713334029
#> EM: Iteration: 28 || log-likelihood: -483.110601518092
#> EM: Iteration: 29 || log-likelihood: -483.108570930447
#> EM: Iteration: 30 || log-likelihood: -483.106617619433
#> EM: Iteration: 31 || log-likelihood: -483.104737943111
#> EM: Iteration: 32 || log-likelihood: -483.102928525089
#> EM: Iteration: 33 || log-likelihood: -483.101186219163
#> EM: Iteration: 34 || log-likelihood: -483.099508080551
#> EM: Iteration: 35 || log-likelihood: -483.097890419535
#> EM: Iteration: 36 || log-likelihood: -483.096331069221
#> EM: Iteration: 37 || log-likelihood: -483.094829472842
#> EM: Iteration: 38 || log-likelihood: -483.093382056145
#> EM: Iteration: 39 || log-likelihood: -483.091986682919
#> EM: Iteration: 40 || log-likelihood: -483.090641328988
#> EM: Iteration: 41 || log-likelihood: -483.089344071025
#> EM: Iteration: 42 || log-likelihood: -483.088093073901
#> EM: Iteration: 43 || log-likelihood: -483.086886579918
#> EM: Iteration: 44 || log-likelihood: -483.085715071196
#> EM: Iteration: 45 || log-likelihood: -483.084573116774
#> EM: Iteration: 46 || log-likelihood: -483.083470711643
#> EM: Iteration: 47 || log-likelihood: -483.082406654836
#> EM: Iteration: 48 || log-likelihood: -483.081379368121
#> EM: Iteration: 49 || log-likelihood: -483.080386477543
#> EM: Iteration: 50 || log-likelihood: -483.07942579642
#> EM: Iteration: 51 || log-likelihood: -483.078496034224
#> EM: Iteration: 52 || log-likelihood: -483.077595965293
#> EM: Iteration: 53 || log-likelihood: -483.076724425087
#> EM: Iteration: 54 || log-likelihood: -483.075880305629
#> EM: Iteration: 55 || log-likelihood: -483.075062551509
#> EM: Iteration: 56 || log-likelihood: -483.074270156377
#> EM: Iteration: 57 || log-likelihood: -483.073502159877
#> EM: Iteration: 58 || log-likelihood: -483.072757644915
#> EM: Iteration: 59 || log-likelihood: -483.072035735215
#> EM: Iteration: 60 || log-likelihood: -483.071335593091
#> EM: Iteration: 61 || log-likelihood: -483.070656417406
#> EM: Iteration: 62 || log-likelihood: -483.069997441684
#> EM: Iteration: 63 || log-likelihood: -483.069357932355
#> EM: Iteration: 64 || log-likelihood: -483.068737187111
#> EM: Iteration: 65 || log-likelihood: -483.068134533368
#> EM: Iteration: 66 || log-likelihood: -483.067549326821
#> EM: Iteration: 67 || log-likelihood: -483.066980950077
#> EM: Iteration: 68 || log-likelihood: -483.066428811373
#> EM: Iteration: 69 || log-likelihood: -483.065892343355
#> EM: Iteration: 70 || log-likelihood: -483.065371001935
#> EM: Iteration: 71 || log-likelihood: -483.064864265198
#> EM: Iteration: 72 || log-likelihood: -483.064371632372
#> EM: Iteration: 73 || log-likelihood: -483.063892622854

snmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-8-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-4.png" style="display: block; margin: auto;" />

</details>

<details>

<summary>StMoE</summary>

``` r

n <- 1000 # Size of the sample
K <- 2 # Number of regressors/experts
p <- 1 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

alphak <- matrix(c(0, 8), ncol = K - 1) # Parameters of the gating network
betak <- matrix(c(0, -1, 0, 1), ncol = K) # Regression coefficients of the experts
sigmak <- c(0.1, 0.1) # Standard deviations of the experts
lambdak <- c(3, 5) # Skewness parameters of the experts
nuk <- c(5, 7) # Degrees of freedom of the experts network t densities
x <- seq.int(from = -1, to = 1, length.out = n) # Inputs (predictors)

# Generate sample of size n
sample <- sampleUnivSTMoE(alphak = alphak, betak = betak, sigmak = sigmak, 
                          lambdak = lambdak, nuk = nuk, x = x)

n_tries <- 1
max_iter <- 1500
threshold <- 1e-5
verbose <- TRUE
verbose_IRLS <- FALSE

stmoe <- emStMoE(x, matrix(sample$y), K, p, q, n_tries, max_iter, 
                 threshold, verbose, verbose_IRLS)
#> EM: Iteration: 1 || log-likelihood: -416.589671672032
#> EM: Iteration: 2 || log-likelihood: -366.190783693148
#> EM: Iteration: 3 || log-likelihood: -306.728099677141
#> EM: Iteration: 4 || log-likelihood: -192.277742906065
#> EM: Iteration: 5 || log-likelihood: 17.48812280616
#> EM: Iteration: 6 || log-likelihood: 283.427752987214
#> EM: Iteration: 7 || log-likelihood: 544.425706472775
#> EM: Iteration: 8 || log-likelihood: 750.088155099192
#> EM: Iteration: 9 || log-likelihood: 873.874022363969
#> EM: Iteration: 10 || log-likelihood: 936.288416440756
#> EM: Iteration: 11 || log-likelihood: 953.497019546085
#> EM: Iteration: 12 || log-likelihood: 969.76239921732
#> EM: Iteration: 13 || log-likelihood: 985.961588273355
#> EM: Iteration: 14 || log-likelihood: 995.371154531362
#> EM: Iteration: 15 || log-likelihood: 999.238118570632
#> EM: Iteration: 16 || log-likelihood: 1000.52286941604
#> EM: Iteration: 17 || log-likelihood: 1001.76478199719
#> EM: Iteration: 18 || log-likelihood: 1003.68910013771
#> EM: Iteration: 19 || log-likelihood: 1005.66457718273
#> EM: Iteration: 20 || log-likelihood: 1007.1993499477
#> EM: Iteration: 21 || log-likelihood: 1008.35216788406
#> EM: Iteration: 22 || log-likelihood: 1009.3564274068
#> EM: Iteration: 23 || log-likelihood: 1010.33696196047
#> EM: Iteration: 24 || log-likelihood: 1011.27544855329
#> EM: Iteration: 25 || log-likelihood: 1012.11652451818
#> EM: Iteration: 26 || log-likelihood: 1012.84922757186
#> EM: Iteration: 27 || log-likelihood: 1013.49062406265
#> EM: Iteration: 28 || log-likelihood: 1014.07127469855
#> EM: Iteration: 29 || log-likelihood: 1014.59628834174
#> EM: Iteration: 30 || log-likelihood: 1015.06852883567
#> EM: Iteration: 31 || log-likelihood: 1015.48444871083
#> EM: Iteration: 32 || log-likelihood: 1015.85067316618
#> EM: Iteration: 33 || log-likelihood: 1016.17662265643
#> EM: Iteration: 34 || log-likelihood: 1016.46859542023
#> EM: Iteration: 35 || log-likelihood: 1016.7294069402
#> EM: Iteration: 36 || log-likelihood: 1016.96103781641
#> EM: Iteration: 37 || log-likelihood: 1017.16606878864
#> EM: Iteration: 38 || log-likelihood: 1017.34802637535
#> EM: Iteration: 39 || log-likelihood: 1017.51150338277
#> EM: Iteration: 40 || log-likelihood: 1017.65884700879
#> EM: Iteration: 41 || log-likelihood: 1017.7909199209
#> EM: Iteration: 42 || log-likelihood: 1017.9084664512
#> EM: Iteration: 43 || log-likelihood: 1018.01072771378
#> EM: Iteration: 44 || log-likelihood: 1018.09869848672
#> EM: Iteration: 45 || log-likelihood: 1018.17550875712
#> EM: Iteration: 46 || log-likelihood: 1018.24245744145
#> EM: Iteration: 47 || log-likelihood: 1018.29735484728
#> EM: Iteration: 48 || log-likelihood: 1018.34185004423
#> EM: Iteration: 49 || log-likelihood: 1018.37825786282
#> EM: Iteration: 50 || log-likelihood: 1018.40846568505
#> EM: Iteration: 51 || log-likelihood: 1018.43354060154
#> EM: Iteration: 52 || log-likelihood: 1018.45413207974
#> EM: Iteration: 53 || log-likelihood: 1018.47075103
#> EM: Iteration: 54 || log-likelihood: 1018.48387561316
#> EM: Iteration: 55 || log-likelihood: 1018.49410879439
#> EM: Iteration: 56 || log-likelihood: 1018.50174141832

stmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-9-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-9-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-9-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-9-4.png" style="display: block; margin: auto;" />

</details>

# References

<div id="refs" class="references">

<div id="ref-item9">

Huynh, Tuyen, and Faicel Chamroukhi. 2019. “Estimation and Feature
Selection in Mixtures of Generalized Linear Experts Models.”
*Submitted*. <https://chamroukhi.com/papers/prEMME.pdf>.

</div>

<div id="ref-item1">

Chamroukhi, F, and Bao T Huynh. 2019. “Regularized Maximum Likelihood
Estimation and Feature Selection in Mixtures-of-Experts Models.”
*Journal de La Societe Francaise de Statistique* 160(1): 57–85.

</div>

<div id="ref-item2">

Nguyen, Hien D., and F. Chamroukhi. 2018. “Practical and Theoretical
Aspects of Mixture-of-Experts Modeling: An Overview.” *Wiley
Interdisciplinary Reviews: Data Mining and Knowledge Discovery*,
e1246–n/a. <https://doi.org/10.1002/widm.1246>.

</div>

<div id="ref-item3">

Chamroukhi", F. 2017. “Skew T Mixture of Experts.” *Neurocomputing -
Elsevier* 266: 390–408. <https://chamroukhi.com/papers/STMoE.pdf>.

</div>

<div id="ref-item8">

Chamroukhi, F. 2016. “Robust Mixture of Experts Modeling Using the
\(t\)-Distribution.” *Neural Networks - Elsevier* 79: 20–36.
<https://chamroukhi.com/papers/TMoE.pdf>.

</div>

<div id="ref-item4">

Chamroukhi", F. 2016. “Skew-Normal Mixture of Experts.” In *The
International Joint Conference on Neural Networks (Ijcnn)*.
<https://chamroukhi.com/papers/Chamroukhi-SNMoE-IJCNN2016.pdf>.

</div>

<div id="ref-item6">

Chamroukhi, F. 2015. “Statistical Learning of Latent Data Models for
Complex Data Analysis.” Habilitation Thesis (HDR), Université de Toulon.
<https://chamroukhi.com/Dossier/FChamroukhi-Habilitation.pdf>.

</div>

<div id="ref-item5">

Chamroukhi, F. 2010. “Hidden Process Regression for Curve Modeling,
Classification and Tracking.” Ph.D. Thesis, Université de Technologie de
Compiègne. <https://chamroukhi.com/papers/FChamroukhi-Thesis.pdf>.

</div>

<div id="ref-item7">

Chamroukhi, F., A. Samé, G. Govaert, and P. Aknin. 2009. “Time Series
Modeling by a Regression Approach Based on a Latent Process.” *Neural
Networks* 22 (5-6): 593–602.
<https://chamroukhi.com/papers/Chamroukhi_Neural_Networks_2009.pdf>.

</div>

</div>
