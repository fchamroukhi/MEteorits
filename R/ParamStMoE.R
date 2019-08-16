#' A Reference Class which contains parameters of a MRHLP model.
#'
#' ParamMRHLP contains all the parameters of a MRHLP model.
#'
#' @field X Numeric vector of length \emph{n} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{n}}.
#' @field Y Numeric vector of length \emph{n} representing the observed
#'   response/output \eqn{y_{1},\dots,y_{n}}.
#' @field n Numeric. Length of the response/output vector `Y`.
#' @field K The number of mixture components.
#' @field p The order of the polynomial regression.
#' @field q The dimension of the logistic regression. For the purpose of
#'   segmentation, it must be set to 1.
#' @field df degree of freedom
#' @field alpha is the parameter vector of the logistic model with \eqn{alpha_K}
#'   being the null vector.
#' @field beta is the vector of regression coefficients of component k, the
#'   updates for each of the expert component parameters consist in analytically
#'   solving a weighted Gaussian linear regression problem.
#' @field sigma2 The variances for the \emph{K} mixture component.
#' @field lambda skewness parameter
#' @field delta the skewness parameter lambda (by equivalence delta)
#' @field nuk degrees of freedom
#' @export
ParamStMoE <- setRefClass(
  "ParamStMoE",
  fields = list(

    X = "numeric",
    Y = "numeric",
    n = "numeric",
    phiBeta = "list",
    phiAlpha = "list",

    K = "numeric", # Number of components
    p = "numeric", # Dimension of beta (order of polynomial regression)
    q = "numeric", # Dimension of w (order of logistic regression)
    df = "numeric", # Degree of freedom

    alpha = "matrix",
    beta = "matrix",
    sigma2 = "matrix",
    lambda = "matrix",
    delta = "matrix",
    nuk = "matrix"
  ),
  methods = list(
    initialize = function(X = numeric(), Y = numeric(1), K = 1, p = 3, q = 1) {

      X <<- X
      Y <<- Y
      n <<- length(Y)
      phiBeta <<- designmatrix(x = X, p = p)
      phiAlpha <<- designmatrix(x = X, p = q)

      df <<- (q + 1) * (K - 1) + (p + 1) * K + K + K + K
      K <<- K
      p <<- p
      q <<- q

      alpha <<- matrix(0, q + 1, K - 1)
      beta <<- matrix(NA, p + 1, K)
      sigma2 <<- matrix(NA, 1, K)
      lambda <<- matrix(NA, K)
      delta <<- matrix(NA, K)
    },

    initParam = function(try_EM, segmental = FALSE) {
      "Method to initialize parameters \\code{alpha}, \\code{beta} and
      \\code{sigma2}."

      # Initialize the regression parameters (coefficents and variances):
      if (!segmental) {

        klas <- sample(1:K, n, replace = TRUE)

        for (k in 1:K) {

          Xk <- phiBeta$XBeta[klas == k,]
          yk <- Y[klas == k]

          beta[, k] <<- solve(t(Xk) %*% Xk) %*% t(Xk) %*% yk

          sigma2[k] <<- sum((yk - Xk %*% beta[, k]) ^ 2) / length(yk)
        }
      } else {# Segmental : segment uniformly the data and estimate the parameters

        nk <- round(n / K) - 1

        klas <- rep.int(0, n)

        for (k in 1:K) {
          i <- (k - 1) * nk + 1
          j <- (k * nk)
          yk <- matrix(Y[i:j])
          Xk <- phiBeta$XBeta[i:j, ]

          beta[, k] <<- solve(t(Xk) %*% Xk, tol = 0) %*% (t(Xk) %*% yk)

          muk <- Xk %*% beta[, k, drop = FALSE]

          sigma2[k] <<- t(yk - muk) %*% (yk - muk) / length(yk)

          klas[i:j] <- k
        }
      }

      # Intialize the softmax parameters
      Z <- matrix(0, nrow = n, ncol = K)
      Z[klas %*% ones(1, K) == ones(n, 1) %*% seq(K)] <- 1
      tau <- Z
      res <- IRLS(phiAlpha$XBeta, tau, ones(nrow(tau), 1), alpha)
      alpha <<- res$W

      # Initialize the skewness parameter Lambdak (by equivalence delta)
      lambda <<- -1 + 2 * rand(1, K)
      delta <<- lambda / sqrt(1 + lambda ^ 2)

      # Intitialization of the degrees of freedom
      nuk <<- 50 * rand(1, K)
    },

    MStep = function(statStMoE, calcAlpha = FALSE, calcBeta = FALSE, calcSigma2 = FALSE, calcLambda = FALSE, calcNu = FALSE, verbose_IRLS = FALSE) {
      "Method used in the EM algorithm to learn the parameters of the StMoE model
      based on statistics provided by \\code{statStMoE}."

      reg_irls <- 0

      if (calcAlpha) {

        res_irls <- IRLS(phiAlpha$XBeta, statStMoE$tik, ones(nrow(statStMoE$tik), 1), alpha, verbose_IRLS)
        reg_irls <- res_irls$reg_irls
        alpha <<- res_irls$W
      }

      # Update the regression coefficients
      if (calcBeta) {

        for (k in 1:K) {
          TauikWik <- (statStMoE$tik[, k] * statStMoE$wik[, k]) %*% ones(1, p + 1)
          TauikX <- phiBeta$XBeta * (statStMoE$tik[, k] %*% ones(1, p + 1))
          betak <- solve((t(TauikWik * phiBeta$XBeta) %*% phiBeta$XBeta), tol = 0) %*% (t(TauikX) %*% ((statStMoE$wik[, k] * Y) - (delta[k] * statStMoE$E1ik[, k])))
          beta[, k] <<- betak
        }

      }

      # Update the variances sigma2k
      if (calcSigma2) {

        for (k in 1:K) {
          sigma2[k] <<- sum(statStMoE$tik[, k] * (statStMoE$wik[, k] * ((Y - phiBeta$XBeta %*% beta[, k]) ^ 2) - 2 * delta[k] * statStMoE$E1ik[, k] * (Y - phiBeta$XBeta %*% beta[, k]) + statStMoE$E2ik[, k])) / (2 * (1 - delta[k] ^ 2) * sum(statStMoE$tik[, k]))
        }
      }

      # Update the deltak (the skewness parameter)
      if (calcLambda) {

        for (k in 1:K) {
          try(lambda[k] <<- uniroot(f <- function(lmbda) {
            return((lmbda / sqrt(1 + lmbda ^ 2)) * (1 - (lmbda ^ 2 / (1 + lmbda ^ 2))) *
                     sum(statStMoE$tik[, k])
                   + (1 + (lmbda ^ 2 / (1 + lmbda ^ 2))) * sum(statStMoE$tik[, k] * statStMoE$dik[, k] *
                                                                 statStMoE$E1ik[, k] / sqrt(sigma2[k]))
                   - (lmbda / sqrt(1 + lmbda ^ 2)) * sum(statStMoE$tik[, k] * (
                     statStMoE$wik[, k] * (statStMoE$dik[, k] ^ 2) + statStMoE$E2ik[, k] / (sqrt(sigma2[k]) ^ 2)
                   ))
            )
          }, c(-100, 100), extendInt = "yes")$root,
          silent = TRUE)

          delta[k] <<- lambda[k] / sqrt(1 + lambda[k] ^ 2)
        }
      }

      if (calcNu) {

        for (k in 1:K) {
          try(nuk[k] <<- suppressWarnings(uniroot(f <- function(nnu) {
            return(-psigamma((nnu) / 2) + log((nnu) / 2) + 1 + sum(statStMoE$tik[, k] * (statStMoE$E3ik[, k] - statStMoE$wik[, k])) /
                     sum(statStMoE$tik[, k]))
          }, c(0, 100))$root), silent = TRUE)
        }
      }

      return(reg_irls)
    }
  )
)
