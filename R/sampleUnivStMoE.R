sampleUnivSN <- function(mu, sigma, lambda, n = 1) {

  delta = lambda / sqrt(1 + lambda ^ 2)

  u <- stats::rnorm(n = n, mean = 0, sd = sigma)
  e <- stats::rnorm(n = n, mean = 0, sd = sigma)
  y <- mu + delta * abs(u) + sqrt(1 - delta ^ 2) * e

  return(y)
}

sampleUnivSt <- function(mu, sigma, nu, lambda, n = 1) {

  e <- sampleUnivSN(0, 1, lambda, n = 1)

  # A gamma variable
  w <- stats::rgamma(n = 1, shape = nu / 2, scale = 2 / nu)

  # A skew-t variable
  y <- mu + sigma * e / sqrt(w)

  return(y)
}

#' Draw a sample from a univariate skew-t mixture.
#'
#' @param alphak The parameters of the gating network. `alphak` is a matrix of
#'   size \emph{(q + 1, K - 1)}, with \emph{K - 1}, the number of regressors
#'   (experts) and \emph{q} the order of the logistic regression
#' @param betak Matrix of size \emph{(p + 1, K)} representing the regression
#'   coefficients of the experts network.
#' @param sigmak Vector of length \emph{K} giving the standard deviations of
#'   the experts network.
#' @param lambdak Vector of length \emph{K} giving the skewness parameter of
#'   each experts.
#' @param nuk Vector of length \emph{K} giving the degrees of freedom of the
#'   experts network t densities.
#' @param x A vector og length \emph{n} representing the inputs (predictors).
#'
#' @return A list with the output variable `y` and statistics.
#' \itemize{
#'   \item `y` Vector of length \emph{n} giving the output variable.
#'   \item `zi` A vector of size \emph{n} giving the hidden label of the
#'     expert component generating the i-th observation. Its elements are
#'     \eqn{zi[i] = k}, if the i-th observation has been generated by the
#'     k-th expert.
#'   \item `z` A matrix of size \emph{(n, K)} giving the values of the binary
#'     latent component indicators \eqn{Z_{ik}}{Zik} such that
#'     \eqn{Z_{ik} = 1}{Zik = 1} iff \eqn{Z_{i} = k}{Zi = k}.
#'  \item `stats` A list whose elements are:
#'    \itemize{
#'      \item `Ey_k` Matrix of size \emph{(n, K)} giving the conditional
#'        expectation of Yi the output variable given the value of the
#'        hidden label of the expert component generating the ith observation
#'        \emph{zi = k}, and the value of predictor \emph{X = xi}.
#'      \item `Ey` Vector of length \emph{n} giving the conditional expectation
#'        of Yi given the value of predictor \emph{X = xi}.
#'      \item `Vary_k` Vector of length \emph{k} representing the conditional
#'        variance of Yi given \emph{zi = k}, and \emph{X = xi}.
#'      \item `Vary` Vector of length \emph{n} giving the conditional expectation
#'        of Yi given \emph{X = xi}.
#'    }
#' }
#' @export
#'
#' @examples
#' n <- 500 # Size of the sample
#' alphak <- matrix(c(0, 8), ncol = 1) # Parameters of the gating network
#' betak <- matrix(c(0, -2.5, 0, 2.5), ncol = 2) # Regression coefficients of the experts
#' sigmak <- c(0.5, 0.5) # Standard deviations of the experts
#' lambdak <- c(3, 5) # Skewness parameters of the experts
#' nuk <- c(5, 7) # Degrees of freedom of the experts network t densities
#' x <- seq.int(from = -1, to = 1, length.out = n) # Inputs (predictors)
#'
#' # Generate sample of size n
#' sample <- sampleUnivStMoE(alphak = alphak, betak = betak, sigmak = sigmak,
#'                           lambdak = lambdak, nuk = nuk, x = x)
#'
#' # Plot points and estimated means
#' plot(x, sample$y, pch = 4)
#' lines(x, sample$stats$Ey_k[, 1], col = "blue", lty = "dotted", lwd = 1.5)
#' lines(x, sample$stats$Ey_k[, 2], col = "blue", lty = "dotted", lwd = 1.5)
#' lines(x, sample$stats$Ey, col = "red", lwd = 1.5)
sampleUnivStMoE <- function(alphak, betak, sigmak, lambdak, nuk, x) {

    n <- length(x)

    p <- nrow(betak) - 1
    q <- nrow(alphak) - 1
    K = ncol(betak)

    # Build the regression design matrices
    XBeta <- designmatrix(x, p, q)$XBeta # For the polynomial regression
    XAlpha <- designmatrix(x, p, q)$Xw # For the logistic regression

    y <- rep.int(x = 0, times = n)
    z <- zeros(n, K)
    zi <- rep.int(x = 0, times = n)

    deltak <- lambdak / sqrt(1 + lambdak ^ 2)

    # Calculate the mixing proportions piik:
    piik <- multinomialLogit(alphak, XAlpha, zeros(n, K), ones(n, 1))$piik

    for (i in 1:n) {
      zik <- stats::rmultinom(n = 1, size = 1, piik[i,])

      mu <- as.numeric(XBeta[i,] %*% betak[, zik == 1])
      sigma <- sigmak[zik == 1]
      lambda <- lambdak[zik == 1]
      nu <- nuk[zik == 1]

      y[i] <- sampleUnivSt(mu = mu, sigma = sigma, nu = nu, lambda = lambda)
      z[i, ] <- t(zik)
      zi[i] <- which.max(zik)

    }

    # Statistics (means, variances)
    Xi_nuk = sqrt(nuk / pi) * (gamma(nuk / 2 - 1 / 2)) / (gamma(nuk / 2))

    # E[yi|xi,zi=k]
    Ey_k <- XBeta %*% betak + ones(n, 1) %*% (sigmak * deltak * Xi_nuk)

    # E[yi|xi]
    Ey <- rowSums(piik * Ey_k)

    # Var[yi|xi,zi=k]
    Vary_k <- (nuk / (nuk - 2) - (deltak ^ 2) * (Xi_nuk ^ 2)) * (sigmak ^ 2)

    # Var[yi|xi]
    Vary <- rowSums(piik * (Ey_k ^ 2 + ones(n, 1) %*% Vary_k)) - Ey ^ 2

    stats <- list()
    stats$Ey_k <- Ey_k
    stats$Ey <- Ey
    stats$Vary_k <- Vary_k
    stats$Vary <- Vary

    return(list(y = y, zi = zi, z = z, stats = stats))
}
