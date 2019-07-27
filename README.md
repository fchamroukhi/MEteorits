
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- badges: start -->
[![Travis build status](https://travis-ci.org/fchamroukhi/MEteorits.svg?branch=master)](https://travis-ci.org/fchamroukhi/MEteorits) <!-- badges: end -->

**MEteorits:** Mixtures-of-ExperTs modEling for cOmplex and non-noRmal dIsTributions
====================================================================================

MEteoritS is an open source toolbox (available in R and Matlab) containg several original and flexible mixtures-of-experts models to model, cluster and classify heteregenous data in many complex situations where the data are distributed according to non-normal and possibly skewed distributions, and when they might be corrupted by atypical observations. The toolbox also contains sparse mixture-of-experts models for high-dimensional data.

Our (dis-)covered meteorits are for instance the following ones:

-   NMoE;
-   NNMoE;
-   tMoE;
-   StMoE;
-   SNMoE;
-   RMoE.

The models and algorithms are developped and written in Matlab by Faicel Chamroukhi, and translated and designed into R packages by Florian Lecocq, Marius Bartcus and Faicel Chamroukhi.

Installation
============

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
browseVignettes("meteorits")
```

Usage
=====

``` r
library(meteorits)
```

<details> <summary>NMoE</summary>

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
#> EM: Iteration: 1 || log-likelihood: -918.333826741266
#> EM: Iteration: 2 || log-likelihood: -730.636185921978
#> EM: Iteration: 3 || log-likelihood: -724.769640161034
#> EM: Iteration: 4 || log-likelihood: -721.417328425261
#> EM: Iteration: 5 || log-likelihood: -719.448396496216
#> EM: Iteration: 6 || log-likelihood: -718.279851732195
#> EM: Iteration: 7 || log-likelihood: -717.575483264976
#> EM: Iteration: 8 || log-likelihood: -717.142055689221
#> EM: Iteration: 9 || log-likelihood: -716.868343432225
#> EM: Iteration: 10 || log-likelihood: -716.690040906615
#> EM: Iteration: 11 || log-likelihood: -716.56969630021
#> EM: Iteration: 12 || log-likelihood: -716.485272020775
#> EM: Iteration: 13 || log-likelihood: -716.423637128883
#> EM: Iteration: 14 || log-likelihood: -716.376855312379
#> EM: Iteration: 15 || log-likelihood: -716.340052627504
#> EM: Iteration: 16 || log-likelihood: -716.310181488938
#> EM: Iteration: 17 || log-likelihood: -716.285295923175
#> EM: Iteration: 18 || log-likelihood: -716.264124199742
#> EM: Iteration: 19 || log-likelihood: -716.245812386948
#> EM: Iteration: 20 || log-likelihood: -716.229769854626
#> EM: Iteration: 21 || log-likelihood: -716.215575032462
#> EM: Iteration: 22 || log-likelihood: -716.202917273075
#> EM: Iteration: 23 || log-likelihood: -716.191560527525
#> EM: Iteration: 24 || log-likelihood: -716.181320308884
#> EM: Iteration: 25 || log-likelihood: -716.172048823641
#> EM: Iteration: 26 || log-likelihood: -716.16362517499
#> EM: Iteration: 27 || log-likelihood: -716.1559487537
#> EM: Iteration: 28 || log-likelihood: -716.148934661457

nmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-6-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-6-4.png" style="display: block; margin: auto;" /> </details>

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
#> EM: Iteration: 1 || log-likelihood: -698.895642314925
#> EM: Iteration: 2 || log-likelihood: -448.511589127814
#> EM: Iteration: 3 || log-likelihood: -442.761413625088
#> EM: Iteration: 4 || log-likelihood: -441.487263834871
#> EM: Iteration: 5 || log-likelihood: -441.095669438027
#> EM: Iteration: 6 || log-likelihood: -440.948322638362
#> EM: Iteration: 7 || log-likelihood: -440.878887362616
#> EM: Iteration: 8 || log-likelihood: -440.837884684494
#> EM: Iteration: 9 || log-likelihood: -440.808570123271
#> EM: Iteration: 10 || log-likelihood: -440.784680248776
#> EM: Iteration: 11 || log-likelihood: -440.76369799371
#> EM: Iteration: 12 || log-likelihood: -440.744545424279
#> EM: Iteration: 13 || log-likelihood: -440.726723288367
#> EM: Iteration: 14 || log-likelihood: -440.709973469334
#> EM: Iteration: 15 || log-likelihood: -440.694142469473
#> EM: Iteration: 16 || log-likelihood: -440.679124954286
#> EM: Iteration: 17 || log-likelihood: -440.664839863643
#> EM: Iteration: 18 || log-likelihood: -440.651219973943
#> EM: Iteration: 19 || log-likelihood: -440.638207098726
#> EM: Iteration: 20 || log-likelihood: -440.625749698679
#> EM: Iteration: 21 || log-likelihood: -440.613801552085
#> EM: Iteration: 22 || log-likelihood: -440.602320914726
#> EM: Iteration: 23 || log-likelihood: -440.591269922958
#> EM: Iteration: 24 || log-likelihood: -440.580614130521
#> EM: Iteration: 25 || log-likelihood: -440.57032212814
#> EM: Iteration: 26 || log-likelihood: -440.560365220492
#> EM: Iteration: 27 || log-likelihood: -440.550717146567
#> EM: Iteration: 28 || log-likelihood: -440.541353834892
#> EM: Iteration: 29 || log-likelihood: -440.532253187796
#> EM: Iteration: 30 || log-likelihood: -440.523394890402
#> EM: Iteration: 31 || log-likelihood: -440.514760240967
#> EM: Iteration: 32 || log-likelihood: -440.506331999771
#> EM: Iteration: 33 || log-likelihood: -440.498094254248
#> EM: Iteration: 34 || log-likelihood: -440.490032296012
#> EM: Iteration: 35 || log-likelihood: -440.482132520173
#> EM: Iteration: 36 || log-likelihood: -440.47438232061
#> EM: Iteration: 37 || log-likelihood: -440.466770005508
#> EM: Iteration: 38 || log-likelihood: -440.459284718861
#> EM: Iteration: 39 || log-likelihood: -440.451916369702
#> EM: Iteration: 40 || log-likelihood: -440.444655568204
#> EM: Iteration: 41 || log-likelihood: -440.437493567899
#> EM: Iteration: 42 || log-likelihood: -440.430422213366
#> EM: Iteration: 43 || log-likelihood: -440.423433892807
#> EM: Iteration: 44 || log-likelihood: -440.416521494998
#> EM: Iteration: 45 || log-likelihood: -440.409678370167
#> EM: Iteration: 46 || log-likelihood: -440.402898294392
#> EM: Iteration: 47 || log-likelihood: -440.396175437184
#> EM: Iteration: 48 || log-likelihood: -440.389504331907
#> EM: Iteration: 49 || log-likelihood: -440.382879848794
#> EM: Iteration: 50 || log-likelihood: -440.376297170278
#> EM: Iteration: 51 || log-likelihood: -440.369751768425
#> EM: Iteration: 52 || log-likelihood: -440.363239384285
#> EM: Iteration: 53 || log-likelihood: -440.356756008959
#> EM: Iteration: 54 || log-likelihood: -440.350297866237
#> EM: Iteration: 55 || log-likelihood: -440.343861396663
#> EM: Iteration: 56 || log-likelihood: -440.337443242896
#> EM: Iteration: 57 || log-likelihood: -440.331040236249
#> EM: Iteration: 58 || log-likelihood: -440.324649384309
#> EM: Iteration: 59 || log-likelihood: -440.318267859539
#> EM: Iteration: 60 || log-likelihood: -440.31189298878
#> EM: Iteration: 61 || log-likelihood: -440.305522243569
#> EM: Iteration: 62 || log-likelihood: -440.299153231222
#> EM: Iteration: 63 || log-likelihood: -440.292783686595
#> EM: Iteration: 64 || log-likelihood: -440.286411464491
#> EM: Iteration: 65 || log-likelihood: -440.280034532639
#> EM: Iteration: 66 || log-likelihood: -440.273650965219
#> EM: Iteration: 67 || log-likelihood: -440.267258936868
#> EM: Iteration: 68 || log-likelihood: -440.26085671716
#> EM: Iteration: 69 || log-likelihood: -440.254442665467
#> EM: Iteration: 70 || log-likelihood: -440.248015226273
#> EM: Iteration: 71 || log-likelihood: -440.241572924767
#> EM: Iteration: 72 || log-likelihood: -440.23511436285
#> EM: Iteration: 73 || log-likelihood: -440.228638215345
#> EM: Iteration: 74 || log-likelihood: -440.222143226624
#> EM: Iteration: 75 || log-likelihood: -440.215628207377
#> EM: Iteration: 76 || log-likelihood: -440.209092031687
#> EM: Iteration: 77 || log-likelihood: -440.20253363434
#> EM: Iteration: 78 || log-likelihood: -440.195952008308
#> EM: Iteration: 79 || log-likelihood: -440.189346202457
#> EM: Iteration: 80 || log-likelihood: -440.18271531944
#> EM: Iteration: 81 || log-likelihood: -440.176058513744
#> EM: Iteration: 82 || log-likelihood: -440.16937498992
#> EM: Iteration: 83 || log-likelihood: -440.162664000927
#> EM: Iteration: 84 || log-likelihood: -440.155924846663
#> EM: Iteration: 85 || log-likelihood: -440.149156872597
#> EM: Iteration: 86 || log-likelihood: -440.142359468511
#> EM: Iteration: 87 || log-likelihood: -440.135532067399
#> EM: Iteration: 88 || log-likelihood: -440.128674144427
#> EM: Iteration: 89 || log-likelihood: -440.121785216045
#> EM: Iteration: 90 || log-likelihood: -440.114864839126
#> EM: Iteration: 91 || log-likelihood: -440.107912610258
#> EM: Iteration: 92 || log-likelihood: -440.100928165086
#> EM: Iteration: 93 || log-likelihood: -440.093911177745
#> EM: Iteration: 94 || log-likelihood: -440.086861360342
#> EM: Iteration: 95 || log-likelihood: -440.079778462536
#> EM: Iteration: 96 || log-likelihood: -440.072662271178
#> EM: Iteration: 97 || log-likelihood: -440.065512609984
#> EM: Iteration: 98 || log-likelihood: -440.058329339296
#> EM: Iteration: 99 || log-likelihood: -440.051112355879
#> EM: Iteration: 100 || log-likelihood: -440.04386159278
#> EM: Iteration: 101 || log-likelihood: -440.036577019203
#> EM: Iteration: 102 || log-likelihood: -440.02925864046
#> EM: Iteration: 103 || log-likelihood: -440.021906497954
#> EM: Iteration: 104 || log-likelihood: -440.014520669172
#> EM: Iteration: 105 || log-likelihood: -440.007101267743
#> EM: Iteration: 106 || log-likelihood: -439.999648443516
#> EM: Iteration: 107 || log-likelihood: -439.992162382647
#> EM: Iteration: 108 || log-likelihood: -439.984643307746
#> EM: Iteration: 109 || log-likelihood: -439.977091478
#> EM: Iteration: 110 || log-likelihood: -439.969507189376
#> EM: Iteration: 111 || log-likelihood: -439.961890774771
#> EM: Iteration: 112 || log-likelihood: -439.95424260422
#> EM: Iteration: 113 || log-likelihood: -439.946563085111
#> EM: Iteration: 114 || log-likelihood: -439.938852662397
#> EM: Iteration: 115 || log-likelihood: -439.931111818813
#> EM: Iteration: 116 || log-likelihood: -439.923341075106
#> EM: Iteration: 117 || log-likelihood: -439.915540990258
#> EM: Iteration: 118 || log-likelihood: -439.907712161711
#> EM: Iteration: 119 || log-likelihood: -439.899855225575
#> EM: Iteration: 120 || log-likelihood: -439.891970856843
#> EM: Iteration: 121 || log-likelihood: -439.884059769597
#> EM: Iteration: 122 || log-likelihood: -439.876122717179
#> EM: Iteration: 123 || log-likelihood: -439.868160492366
#> EM: Iteration: 124 || log-likelihood: -439.860173927524
#> EM: Iteration: 125 || log-likelihood: -439.852163894724
#> EM: Iteration: 126 || log-likelihood: -439.84413130586
#> EM: Iteration: 127 || log-likelihood: -439.836077112708
#> EM: Iteration: 128 || log-likelihood: -439.82800230699
#> EM: Iteration: 129 || log-likelihood: -439.819907920371
#> EM: Iteration: 130 || log-likelihood: -439.811795024435
#> EM: Iteration: 131 || log-likelihood: -439.803664730638
#> EM: Iteration: 132 || log-likelihood: -439.795518190183
#> EM: Iteration: 133 || log-likelihood: -439.787356593889
#> EM: Iteration: 134 || log-likelihood: -439.779181171974
#> EM: Iteration: 135 || log-likelihood: -439.770993193829
#> EM: Iteration: 136 || log-likelihood: -439.762793967707
#> EM: Iteration: 137 || log-likelihood: -439.754584840369
#> EM: Iteration: 138 || log-likelihood: -439.746367196673
#> EM: Iteration: 139 || log-likelihood: -439.738142459098
#> EM: Iteration: 140 || log-likelihood: -439.729912087213
#> EM: Iteration: 141 || log-likelihood: -439.721677577068
#> EM: Iteration: 142 || log-likelihood: -439.713440460526
#> EM: Iteration: 143 || log-likelihood: -439.705202304535
#> EM: Iteration: 144 || log-likelihood: -439.696964710297
#> EM: Iteration: 145 || log-likelihood: -439.6887293124
#> EM: Iteration: 146 || log-likelihood: -439.680497777858
#> EM: Iteration: 147 || log-likelihood: -439.672271805064
#> EM: Iteration: 148 || log-likelihood: -439.664053122697
#> EM: Iteration: 149 || log-likelihood: -439.655843488507
#> EM: Iteration: 150 || log-likelihood: -439.647644688065
#> EM: Iteration: 151 || log-likelihood: -439.639458533394
#> EM: Iteration: 152 || log-likelihood: -439.631286861557
#> EM: Iteration: 153 || log-likelihood: -439.623131533124
#> EM: Iteration: 154 || log-likelihood: -439.614994430594
#> EM: Iteration: 155 || log-likelihood: -439.606877456724
#> EM: Iteration: 156 || log-likelihood: -439.598782532766
#> EM: Iteration: 157 || log-likelihood: -439.590711596656
#> EM: Iteration: 158 || log-likelihood: -439.582666601093
#> EM: Iteration: 159 || log-likelihood: -439.574649511574
#> EM: Iteration: 160 || log-likelihood: -439.566662304337
#> EM: Iteration: 161 || log-likelihood: -439.558706964241
#> EM: Iteration: 162 || log-likelihood: -439.550785482581
#> EM: Iteration: 163 || log-likelihood: -439.542899854834
#> EM: Iteration: 164 || log-likelihood: -439.535052078351
#> EM: Iteration: 165 || log-likelihood: -439.527244149998
#> EM: Iteration: 166 || log-likelihood: -439.519478063717
#> EM: Iteration: 167 || log-likelihood: -439.511755808086
#> EM: Iteration: 168 || log-likelihood: -439.50407936379
#> EM: Iteration: 169 || log-likelihood: -439.49645070109
#> EM: Iteration: 170 || log-likelihood: -439.488871777242
#> EM: Iteration: 171 || log-likelihood: -439.481344533897
#> EM: Iteration: 172 || log-likelihood: -439.473870894481
#> EM: Iteration: 173 || log-likelihood: -439.466452761561
#> EM: Iteration: 174 || log-likelihood: -439.459092014205
#> EM: Iteration: 175 || log-likelihood: -439.45179050535
#> EM: Iteration: 176 || log-likelihood: -439.444550059163
#> EM: Iteration: 177 || log-likelihood: -439.437372468433
#> EM: Iteration: 178 || log-likelihood: -439.430259491975
#> EM: Iteration: 179 || log-likelihood: -439.423212852073
#> EM: Iteration: 180 || log-likelihood: -439.41623423195
#> EM: Iteration: 181 || log-likelihood: -439.409325273294
#> EM: Iteration: 182 || log-likelihood: -439.402487573828
#> EM: Iteration: 183 || log-likelihood: -439.395722684951
#> EM: Iteration: 184 || log-likelihood: -439.389032109437
#> EM: Iteration: 185 || log-likelihood: -439.38241729921
#> EM: Iteration: 186 || log-likelihood: -439.375879653218
#> EM: Iteration: 187 || log-likelihood: -439.369420515368
#> EM: Iteration: 188 || log-likelihood: -439.363041172586
#> EM: Iteration: 189 || log-likelihood: -439.35674285296
#> EM: Iteration: 190 || log-likelihood: -439.350526724008
#> EM: Iteration: 191 || log-likelihood: -439.344393891045
#> EM: Iteration: 192 || log-likelihood: -439.338345395682
#> EM: Iteration: 193 || log-likelihood: -439.332382214449
#> EM: Iteration: 194 || log-likelihood: -439.326505257547
#> EM: Iteration: 195 || log-likelihood: -439.320715367732
#> EM: Iteration: 196 || log-likelihood: -439.315013319344
#> EM: Iteration: 197 || log-likelihood: -439.309399817469
#> EM: Iteration: 198 || log-likelihood: -439.303875497255
#> EM: Iteration: 199 || log-likelihood: -439.298440923363
#> EM: Iteration: 200 || log-likelihood: -439.293096589577
#> EM: Iteration: 201 || log-likelihood: -439.28784291855
#> EM: Iteration: 202 || log-likelihood: -439.282680261718
#> EM: Iteration: 203 || log-likelihood: -439.277608899339
#> EM: Iteration: 204 || log-likelihood: -439.272629040697
#> EM: Iteration: 205 || log-likelihood: -439.267740824449
#> EM: Iteration: 206 || log-likelihood: -439.262944319114
#> EM: Iteration: 207 || log-likelihood: -439.258239523704
#> EM: Iteration: 208 || log-likelihood: -439.253626368499
#> EM: Iteration: 209 || log-likelihood: -439.249104715949
#> EM: Iteration: 210 || log-likelihood: -439.24467436172
#> EM: Iteration: 211 || log-likelihood: -439.240335035852

tmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-7-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-7-4.png" style="display: block; margin: auto;" />

</details>

<details> <summary>SNMoE</summary>

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
#> EM: Iteration: 1 || log-likelihood: -745.201260400551
#> EM: Iteration: 2 || log-likelihood: -500.14399139723
#> EM: Iteration: 3 || log-likelihood: -489.595614005796
#> EM: Iteration: 4 || log-likelihood: -484.434987220433
#> EM: Iteration: 5 || log-likelihood: -481.565451043604
#> EM: Iteration: 6 || log-likelihood: -479.920029446256
#> EM: Iteration: 7 || log-likelihood: -478.945594372113
#> EM: Iteration: 8 || log-likelihood: -478.337833317652
#> EM: Iteration: 9 || log-likelihood: -477.932007653966
#> EM: Iteration: 10 || log-likelihood: -477.641219887058
#> EM: Iteration: 11 || log-likelihood: -477.420054970874
#> EM: Iteration: 12 || log-likelihood: -477.244150295594
#> EM: Iteration: 13 || log-likelihood: -477.099736124049
#> EM: Iteration: 14 || log-likelihood: -476.978496313809
#> EM: Iteration: 15 || log-likelihood: -476.875054228518
#> EM: Iteration: 16 || log-likelihood: -476.785715000452
#> EM: Iteration: 17 || log-likelihood: -476.707812636335
#> EM: Iteration: 18 || log-likelihood: -476.639351913993
#> EM: Iteration: 19 || log-likelihood: -476.578793697418
#> EM: Iteration: 20 || log-likelihood: -476.524919049982
#> EM: Iteration: 21 || log-likelihood: -476.476736684946
#> EM: Iteration: 22 || log-likelihood: -476.433452239497
#> EM: Iteration: 23 || log-likelihood: -476.394410323754
#> EM: Iteration: 24 || log-likelihood: -476.359063975426
#> EM: Iteration: 25 || log-likelihood: -476.326952676581
#> EM: Iteration: 26 || log-likelihood: -476.297685981146
#> EM: Iteration: 27 || log-likelihood: -476.270920577888
#> EM: Iteration: 28 || log-likelihood: -476.246367463624
#> EM: Iteration: 29 || log-likelihood: -476.223789420336
#> EM: Iteration: 30 || log-likelihood: -476.202960843496
#> EM: Iteration: 31 || log-likelihood: -476.18372068066
#> EM: Iteration: 32 || log-likelihood: -476.165915647105
#> EM: Iteration: 33 || log-likelihood: -476.149402599653
#> EM: Iteration: 34 || log-likelihood: -476.13405525658
#> EM: Iteration: 35 || log-likelihood: -476.119759021539
#> EM: Iteration: 36 || log-likelihood: -476.106404246338
#> EM: Iteration: 37 || log-likelihood: -476.093907428304
#> EM: Iteration: 38 || log-likelihood: -476.08217963892
#> EM: Iteration: 39 || log-likelihood: -476.071146053791
#> EM: Iteration: 40 || log-likelihood: -476.060767014159
#> EM: Iteration: 41 || log-likelihood: -476.050964743401
#> EM: Iteration: 42 || log-likelihood: -476.041697201213
#> EM: Iteration: 43 || log-likelihood: -476.032919687116
#> EM: Iteration: 44 || log-likelihood: -476.024589230802
#> EM: Iteration: 45 || log-likelihood: -476.016666080877
#> EM: Iteration: 46 || log-likelihood: -476.009113980009
#> EM: Iteration: 47 || log-likelihood: -476.001908746674
#> EM: Iteration: 48 || log-likelihood: -475.995017866527
#> EM: Iteration: 49 || log-likelihood: -475.988398351721
#> EM: Iteration: 50 || log-likelihood: -475.982037222409
#> EM: Iteration: 51 || log-likelihood: -475.975894319199
#> EM: Iteration: 52 || log-likelihood: -475.969956593025
#> EM: Iteration: 53 || log-likelihood: -475.964201029359
#> EM: Iteration: 54 || log-likelihood: -475.958616811002
#> EM: Iteration: 55 || log-likelihood: -475.953189939209
#> EM: Iteration: 56 || log-likelihood: -475.947892121437
#> EM: Iteration: 57 || log-likelihood: -475.942713177278
#> EM: Iteration: 58 || log-likelihood: -475.93763972582
#> EM: Iteration: 59 || log-likelihood: -475.932657665099
#> EM: Iteration: 60 || log-likelihood: -475.927751633475
#> EM: Iteration: 61 || log-likelihood: -475.922906373888
#> EM: Iteration: 62 || log-likelihood: -475.918113634722
#> EM: Iteration: 63 || log-likelihood: -475.913372845909
#> EM: Iteration: 64 || log-likelihood: -475.908651351671
#> EM: Iteration: 65 || log-likelihood: -475.903928207216
#> EM: Iteration: 66 || log-likelihood: -475.899220523714
#> EM: Iteration: 67 || log-likelihood: -475.894517947718
#> EM: Iteration: 68 || log-likelihood: -475.889807284995
#> EM: Iteration: 69 || log-likelihood: -475.885075894965
#> EM: Iteration: 70 || log-likelihood: -475.880313383555
#> EM: Iteration: 71 || log-likelihood: -475.875508686973
#> EM: Iteration: 72 || log-likelihood: -475.870649609515
#> EM: Iteration: 73 || log-likelihood: -475.865722251014
#> EM: Iteration: 74 || log-likelihood: -475.860710316605
#> EM: Iteration: 75 || log-likelihood: -475.855612912421
#> EM: Iteration: 76 || log-likelihood: -475.850431590224
#> EM: Iteration: 77 || log-likelihood: -475.845148937657
#> EM: Iteration: 78 || log-likelihood: -475.839755754302
#> EM: Iteration: 79 || log-likelihood: -475.834242134325
#> EM: Iteration: 80 || log-likelihood: -475.828598046092
#> EM: Iteration: 81 || log-likelihood: -475.822813287309
#> EM: Iteration: 82 || log-likelihood: -475.816877443821
#> EM: Iteration: 83 || log-likelihood: -475.810779847193
#> EM: Iteration: 84 || log-likelihood: -475.804509528868
#> EM: Iteration: 85 || log-likelihood: -475.79805516997
#> EM: Iteration: 86 || log-likelihood: -475.791405047123
#> EM: Iteration: 87 || log-likelihood: -475.784546976024
#> EM: Iteration: 88 || log-likelihood: -475.777468255891
#> EM: Iteration: 89 || log-likelihood: -475.770155619154
#> EM: Iteration: 90 || log-likelihood: -475.762595191483
#> EM: Iteration: 91 || log-likelihood: -475.754772467101
#> EM: Iteration: 92 || log-likelihood: -475.746672303104
#> EM: Iteration: 93 || log-likelihood: -475.738290214479
#> EM: Iteration: 94 || log-likelihood: -475.729617179306
#> EM: Iteration: 95 || log-likelihood: -475.7206302513
#> EM: Iteration: 96 || log-likelihood: -475.711313235203
#> EM: Iteration: 97 || log-likelihood: -475.701649855967
#> EM: Iteration: 98 || log-likelihood: -475.691623519246
#> EM: Iteration: 99 || log-likelihood: -475.681217204847
#> EM: Iteration: 100 || log-likelihood: -475.670413404936
#> EM: Iteration: 101 || log-likelihood: -475.659194085917
#> EM: Iteration: 102 || log-likelihood: -475.647540665876
#> EM: Iteration: 103 || log-likelihood: -475.63543400383
#> EM: Iteration: 104 || log-likelihood: -475.622854398366
#> EM: Iteration: 105 || log-likelihood: -475.60978159314
#> EM: Iteration: 106 || log-likelihood: -475.596194786329
#> EM: Iteration: 107 || log-likelihood: -475.582072641104
#> EM: Iteration: 108 || log-likelihood: -475.567393295324
#> EM: Iteration: 109 || log-likelihood: -475.552134787111
#> EM: Iteration: 110 || log-likelihood: -475.536274147411
#> EM: Iteration: 111 || log-likelihood: -475.519787533109
#> EM: Iteration: 112 || log-likelihood: -475.502651147628
#> EM: Iteration: 113 || log-likelihood: -475.484846944862
#> EM: Iteration: 114 || log-likelihood: -475.466334590211
#> EM: Iteration: 115 || log-likelihood: -475.447092455617
#> EM: Iteration: 116 || log-likelihood: -475.427091750209
#> EM: Iteration: 117 || log-likelihood: -475.406318969525
#> EM: Iteration: 118 || log-likelihood: -475.384768974659
#> EM: Iteration: 119 || log-likelihood: -475.362390285624
#> EM: Iteration: 120 || log-likelihood: -475.339160380845
#> EM: Iteration: 121 || log-likelihood: -475.315063741014
#> EM: Iteration: 122 || log-likelihood: -475.290069155143
#> EM: Iteration: 123 || log-likelihood: -475.264145443257
#> EM: Iteration: 124 || log-likelihood: -475.237297708714
#> EM: Iteration: 125 || log-likelihood: -475.209495721986
#> EM: Iteration: 126 || log-likelihood: -475.180704737509
#> EM: Iteration: 127 || log-likelihood: -475.150909419833
#> EM: Iteration: 128 || log-likelihood: -475.120091467163
#> EM: Iteration: 129 || log-likelihood: -475.088233899384
#> EM: Iteration: 130 || log-likelihood: -475.055320585109
#> EM: Iteration: 131 || log-likelihood: -475.021336598446
#> EM: Iteration: 132 || log-likelihood: -474.986268309002
#> EM: Iteration: 133 || log-likelihood: -474.950158560578
#> EM: Iteration: 134 || log-likelihood: -474.912993398082
#> EM: Iteration: 135 || log-likelihood: -474.874755807276
#> EM: Iteration: 136 || log-likelihood: -474.835442713559
#> EM: Iteration: 137 || log-likelihood: -474.795063304307
#> EM: Iteration: 138 || log-likelihood: -474.753628804438
#> EM: Iteration: 139 || log-likelihood: -474.711154436242
#> EM: Iteration: 140 || log-likelihood: -474.66765974317
#> EM: Iteration: 141 || log-likelihood: -474.623168745423
#> EM: Iteration: 142 || log-likelihood: -474.577710060656
#> EM: Iteration: 143 || log-likelihood: -474.531316990977
#> EM: Iteration: 144 || log-likelihood: -474.484027572353
#> EM: Iteration: 145 || log-likelihood: -474.435884581958
#> EM: Iteration: 146 || log-likelihood: -474.386935499775
#> EM: Iteration: 147 || log-likelihood: -474.337232421747
#> EM: Iteration: 148 || log-likelihood: -474.286830916947
#> EM: Iteration: 149 || log-likelihood: -474.235792131248
#> EM: Iteration: 150 || log-likelihood: -474.184181266992
#> EM: Iteration: 151 || log-likelihood: -474.13206695046
#> EM: Iteration: 152 || log-likelihood: -474.079521163292
#> EM: Iteration: 153 || log-likelihood: -474.02661964415
#> EM: Iteration: 154 || log-likelihood: -473.973440190916
#> EM: Iteration: 155 || log-likelihood: -473.920062773162
#> EM: Iteration: 156 || log-likelihood: -473.866568997538
#> EM: Iteration: 157 || log-likelihood: -473.813041579521
#> EM: Iteration: 158 || log-likelihood: -473.759563801539
#> EM: Iteration: 159 || log-likelihood: -473.706218960677
#> EM: Iteration: 160 || log-likelihood: -473.653089813929
#> EM: Iteration: 161 || log-likelihood: -473.600258029472
#> EM: Iteration: 162 || log-likelihood: -473.547803652242
#> EM: Iteration: 163 || log-likelihood: -473.495804591633
#> EM: Iteration: 164 || log-likelihood: -473.444336138552
#> EM: Iteration: 165 || log-likelihood: -473.393470518276
#> EM: Iteration: 166 || log-likelihood: -473.343276484704
#> EM: Iteration: 167 || log-likelihood: -473.293818960529
#> EM: Iteration: 168 || log-likelihood: -473.245161473666
#> EM: Iteration: 169 || log-likelihood: -473.197361142058
#> EM: Iteration: 170 || log-likelihood: -473.150469685635
#> EM: Iteration: 171 || log-likelihood: -473.104533699363
#> EM: Iteration: 172 || log-likelihood: -473.059594739476
#> EM: Iteration: 173 || log-likelihood: -473.015689378885
#> EM: Iteration: 174 || log-likelihood: -472.972849268245
#> EM: Iteration: 175 || log-likelihood: -472.931101216921
#> EM: Iteration: 176 || log-likelihood: -472.89046729963
#> EM: Iteration: 177 || log-likelihood: -472.850964920613
#> EM: Iteration: 178 || log-likelihood: -472.81260695778
#> EM: Iteration: 179 || log-likelihood: -472.775402405667
#> EM: Iteration: 180 || log-likelihood: -472.739356001485
#> EM: Iteration: 181 || log-likelihood: -472.704468654252
#> EM: Iteration: 182 || log-likelihood: -472.670737680828
#> EM: Iteration: 183 || log-likelihood: -472.638157054413
#> EM: Iteration: 184 || log-likelihood: -472.606717659979
#> EM: Iteration: 185 || log-likelihood: -472.576407935631
#> EM: Iteration: 186 || log-likelihood: -472.547214954814
#> EM: Iteration: 187 || log-likelihood: -472.519122460446
#> EM: Iteration: 188 || log-likelihood: -472.492111596611
#> EM: Iteration: 189 || log-likelihood: -472.466161510698
#> EM: Iteration: 190 || log-likelihood: -472.441252029088
#> EM: Iteration: 191 || log-likelihood: -472.417357369024
#> EM: Iteration: 192 || log-likelihood: -472.394455151595
#> EM: Iteration: 193 || log-likelihood: -472.37251694876
#> EM: Iteration: 194 || log-likelihood: -472.351517057487
#> EM: Iteration: 195 || log-likelihood: -472.331428267679
#> EM: Iteration: 196 || log-likelihood: -472.31222290936
#> EM: Iteration: 197 || log-likelihood: -472.293873010377
#> EM: Iteration: 198 || log-likelihood: -472.276350438092
#> EM: Iteration: 199 || log-likelihood: -472.259627027847
#> EM: Iteration: 200 || log-likelihood: -472.243674698117
#> EM: Iteration: 201 || log-likelihood: -472.228465553118
#> EM: Iteration: 202 || log-likelihood: -472.213971973745
#> EM: Iteration: 203 || log-likelihood: -472.200166697644
#> EM: Iteration: 204 || log-likelihood: -472.187022889188
#> EM: Iteration: 205 || log-likelihood: -472.174514200047
#> EM: Iteration: 206 || log-likelihood: -472.162614821066
#> EM: Iteration: 207 || log-likelihood: -472.151299526096
#> EM: Iteration: 208 || log-likelihood: -472.140543708423
#> EM: Iteration: 209 || log-likelihood: -472.130323410432
#> EM: Iteration: 210 || log-likelihood: -472.120615347084
#> EM: Iteration: 211 || log-likelihood: -472.111396923785
#> EM: Iteration: 212 || log-likelihood: -472.102646249187
#> EM: Iteration: 213 || log-likelihood: -472.094342143435
#> EM: Iteration: 214 || log-likelihood: -472.086464142331
#> EM: Iteration: 215 || log-likelihood: -472.078992497879
#> EM: Iteration: 216 || log-likelihood: -472.071908180502
#> EM: Iteration: 217 || log-likelihood: -472.065192861706
#> EM: Iteration: 218 || log-likelihood: -472.058828912221
#> EM: Iteration: 219 || log-likelihood: -472.052799394769
#> EM: Iteration: 220 || log-likelihood: -472.047088050949
#> EM: Iteration: 221 || log-likelihood: -472.041679287313
#> EM: Iteration: 222 || log-likelihood: -472.036558160409
#> EM: Iteration: 223 || log-likelihood: -472.03171036086
#> EM: Iteration: 224 || log-likelihood: -472.027122196627
#> EM: Iteration: 225 || log-likelihood: -472.022780575609
#> EM: Iteration: 226 || log-likelihood: -472.018672987741
#> EM: Iteration: 227 || log-likelihood: -472.014787486716
#> EM: Iteration: 228 || log-likelihood: -472.01111267148
#> EM: Iteration: 229 || log-likelihood: -472.0076376676
#> EM: Iteration: 230 || log-likelihood: -472.00435210861
#> EM: Iteration: 231 || log-likelihood: -472.001246117426
#> EM: Iteration: 232 || log-likelihood: -471.998310287914
#> EM: Iteration: 233 || log-likelihood: -471.995535666661
#> EM: Iteration: 234 || log-likelihood: -471.992913735028
#> EM: Iteration: 235 || log-likelihood: -471.99043639152
#> EM: Iteration: 236 || log-likelihood: -471.988095934516
#> EM: Iteration: 237 || log-likelihood: -471.985885045402
#> EM: Iteration: 238 || log-likelihood: -471.98379677212
#> EM: Iteration: 239 || log-likelihood: -471.981824513176
#> EM: Iteration: 240 || log-likelihood: -471.979962002097
#> EM: Iteration: 241 || log-likelihood: -471.978203292374
#> EM: Iteration: 242 || log-likelihood: -471.976542742893
#> EM: Iteration: 243 || log-likelihood: -471.974975003845
#> EM: Iteration: 244 || log-likelihood: -471.973495003141
#> EM: Iteration: 245 || log-likelihood: -471.972097933311
#> EM: Iteration: 246 || log-likelihood: -471.970779238897
#> EM: Iteration: 247 || log-likelihood: -471.969534604328
#> EM: Iteration: 248 || log-likelihood: -471.968359942276
#> EM: Iteration: 249 || log-likelihood: -471.967251382476
#> EM: Iteration: 250 || log-likelihood: -471.966205261018
#> EM: Iteration: 251 || log-likelihood: -471.965218110076
#> EM: Iteration: 252 || log-likelihood: -471.96428664809
#> EM: Iteration: 253 || log-likelihood: -471.963407770366
#> EM: Iteration: 254 || log-likelihood: -471.962578540097
#> EM: Iteration: 255 || log-likelihood: -471.961796179788
#> EM: Iteration: 256 || log-likelihood: -471.961058063065
#> EM: Iteration: 257 || log-likelihood: -471.960361706872
#> EM: Iteration: 258 || log-likelihood: -471.959704764021
#> EM: Iteration: 259 || log-likelihood: -471.959085016102
#> EM: Iteration: 260 || log-likelihood: -471.958500366723
#> EM: Iteration: 261 || log-likelihood: -471.957948835086
#> EM: Iteration: 262 || log-likelihood: -471.957428549862
#> EM: Iteration: 263 || log-likelihood: -471.956937743379
#> EM: Iteration: 264 || log-likelihood: -471.956474746086

snmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-8-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-8-4.png" style="display: block; margin: auto;" /> </details>

<details> <summary>StMoE</summary>

``` r

n <- 500 # Size of the sample
K <- 2 # Number of regressors/experts
p <- 1 # Order of the polynomial regression (regressors/experts)
q <- 1 # Order of the logistic regression (gating network)

alphak <- matrix(c(0, 8), ncol = K - 1) # Parameters of the gating network
betak <- matrix(c(0, -2.5, 0, 2.5), ncol = K) # Regression coefficients of the experts
sigmak <- c(.5, .5) # Standard deviations of the experts
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
#> EM: Iteration: 1 || log-likelihood: -706.643829082177
#> EM: Iteration: 2 || log-likelihood: -690.037755077627
#> EM: Iteration: 3 || log-likelihood: -675.867316861858
#> EM: Iteration: 4 || log-likelihood: -655.230490215347
#> EM: Iteration: 5 || log-likelihood: -613.765579527292
#> EM: Iteration: 6 || log-likelihood: -543.237516127722
#> EM: Iteration: 7 || log-likelihood: -454.198803822828
#> EM: Iteration: 8 || log-likelihood: -372.813427324976
#> EM: Iteration: 9 || log-likelihood: -322.973649636215
#> EM: Iteration: 10 || log-likelihood: -299.111197164515
#> EM: Iteration: 11 || log-likelihood: -288.244825893966
#> EM: Iteration: 12 || log-likelihood: -282.481847144175
#> EM: Iteration: 13 || log-likelihood: -279.006259232944
#> EM: Iteration: 14 || log-likelihood: -276.115766700427
#> EM: Iteration: 15 || log-likelihood: -273.522959503468
#> EM: Iteration: 16 || log-likelihood: -271.444960385546
#> EM: Iteration: 17 || log-likelihood: -269.531847925038
#> EM: Iteration: 18 || log-likelihood: -267.690147645276
#> EM: Iteration: 19 || log-likelihood: -265.97749679951
#> EM: Iteration: 20 || log-likelihood: -264.412069716944
#> EM: Iteration: 21 || log-likelihood: -262.97653715855
#> EM: Iteration: 22 || log-likelihood: -261.67259820965
#> EM: Iteration: 23 || log-likelihood: -260.503209512236
#> EM: Iteration: 24 || log-likelihood: -259.442998009258
#> EM: Iteration: 25 || log-likelihood: -258.487500587447
#> EM: Iteration: 26 || log-likelihood: -257.630814915231
#> EM: Iteration: 27 || log-likelihood: -256.859099564437
#> EM: Iteration: 28 || log-likelihood: -256.164740161932
#> EM: Iteration: 29 || log-likelihood: -255.533623554042
#> EM: Iteration: 30 || log-likelihood: -254.958136081335
#> EM: Iteration: 31 || log-likelihood: -254.433483089048
#> EM: Iteration: 32 || log-likelihood: -253.960817043733
#> EM: Iteration: 33 || log-likelihood: -253.535495744952
#> EM: Iteration: 34 || log-likelihood: -253.153525418306
#> EM: Iteration: 35 || log-likelihood: -252.808961704034
#> EM: Iteration: 36 || log-likelihood: -252.494676713182
#> EM: Iteration: 37 || log-likelihood: -252.205540788433
#> EM: Iteration: 38 || log-likelihood: -251.937816384641
#> EM: Iteration: 39 || log-likelihood: -251.691876803401
#> EM: Iteration: 40 || log-likelihood: -251.46687684707
#> EM: Iteration: 41 || log-likelihood: -251.260178715448
#> EM: Iteration: 42 || log-likelihood: -251.069513100362
#> EM: Iteration: 43 || log-likelihood: -250.894249840742
#> EM: Iteration: 44 || log-likelihood: -250.732613864093
#> EM: Iteration: 45 || log-likelihood: -250.582462108336
#> EM: Iteration: 46 || log-likelihood: -250.44265037008
#> EM: Iteration: 47 || log-likelihood: -250.31228209113
#> EM: Iteration: 48 || log-likelihood: -250.191062106594
#> EM: Iteration: 49 || log-likelihood: -250.079104601652
#> EM: Iteration: 50 || log-likelihood: -249.975671075584
#> EM: Iteration: 51 || log-likelihood: -249.880066327861
#> EM: Iteration: 52 || log-likelihood: -249.792532409914
#> EM: Iteration: 53 || log-likelihood: -249.71279815648
#> EM: Iteration: 54 || log-likelihood: -249.639414444292
#> EM: Iteration: 55 || log-likelihood: -249.571577127547
#> EM: Iteration: 56 || log-likelihood: -249.508735953899
#> EM: Iteration: 57 || log-likelihood: -249.45047022741
#> EM: Iteration: 58 || log-likelihood: -249.396743399709
#> EM: Iteration: 59 || log-likelihood: -249.346844568625
#> EM: Iteration: 60 || log-likelihood: -249.300492513486
#> EM: Iteration: 61 || log-likelihood: -249.257419460932
#> EM: Iteration: 62 || log-likelihood: -249.217426509859
#> EM: Iteration: 63 || log-likelihood: -249.180286181651
#> EM: Iteration: 64 || log-likelihood: -249.145820754371
#> EM: Iteration: 65 || log-likelihood: -249.113831618951
#> EM: Iteration: 66 || log-likelihood: -249.084133978329
#> EM: Iteration: 67 || log-likelihood: -249.056557689244
#> EM: Iteration: 68 || log-likelihood: -249.030946000489
#> EM: Iteration: 69 || log-likelihood: -249.007154341196
#> EM: Iteration: 70 || log-likelihood: -248.985049283485
#> EM: Iteration: 71 || log-likelihood: -248.964599840379
#> EM: Iteration: 72 || log-likelihood: -248.945860240276
#> EM: Iteration: 73 || log-likelihood: -248.928634429447
#> EM: Iteration: 74 || log-likelihood: -248.912741014282
#> EM: Iteration: 75 || log-likelihood: -248.898036087267
#> EM: Iteration: 76 || log-likelihood: -248.884404658293
#> EM: Iteration: 77 || log-likelihood: -248.871751626397
#> EM: Iteration: 78 || log-likelihood: -248.859995814216
#> EM: Iteration: 79 || log-likelihood: -248.849092712116
#> EM: Iteration: 80 || log-likelihood: -248.83908182711
#> EM: Iteration: 81 || log-likelihood: -248.829993209613
#> EM: Iteration: 82 || log-likelihood: -248.821737340079
#> EM: Iteration: 83 || log-likelihood: -248.814146049415
#> EM: Iteration: 84 || log-likelihood: -248.807109089356
#> EM: Iteration: 85 || log-likelihood: -248.80054937675
#> EM: Iteration: 86 || log-likelihood: -248.794411475738
#> EM: Iteration: 87 || log-likelihood: -248.788654345376
#> EM: Iteration: 88 || log-likelihood: -248.783245921106
#> EM: Iteration: 89 || log-likelihood: -248.778160319784
#> EM: Iteration: 90 || log-likelihood: -248.773376189854
#> EM: Iteration: 91 || log-likelihood: -248.768873956002
#> EM: Iteration: 92 || log-likelihood: -248.76463612636
#> EM: Iteration: 93 || log-likelihood: -248.760646845127
#> EM: Iteration: 94 || log-likelihood: -248.756891585823
#> EM: Iteration: 95 || log-likelihood: -248.753356930096
#> EM: Iteration: 96 || log-likelihood: -248.750030401345
#> EM: Iteration: 97 || log-likelihood: -248.746900340519
#> EM: Iteration: 98 || log-likelihood: -248.743955813513
#> EM: Iteration: 99 || log-likelihood: -248.741186540847
#> EM: Iteration: 100 || log-likelihood: -248.738582842486
#> EM: Iteration: 101 || log-likelihood: -248.736135592841

stmoe$plot()
```

<img src="man/figures/README-unnamed-chunk-9-1.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-9-2.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-9-3.png" style="display: block; margin: auto;" /><img src="man/figures/README-unnamed-chunk-9-4.png" style="display: block; margin: auto;" /> </details>

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
