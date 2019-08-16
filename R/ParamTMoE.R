#' A Reference Class which contains parameters of a TMoE model.
#'
#' ParamTMoE contains all the parameters of a TMoE model.
#'
#' @field X Numeric vector of length \emph{n} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{n}}.
#' @field Y Numeric vector of length \emph{n} representing the observed
#'   response/output \eqn{y_{1},\dots,y_{n}}.
#' @field n Numeric. Length of the response/output vector `Y`.
#' @field K The number of mixture components.
#' @field p The order of the polynomial regression.
#' @field q The dimension of the logistic regression. For the purpose of
#' segmentation, it must be set to 1.
#' @field df degree of freedom
#' @field alpha is the parameter vector of the logistic model with \eqn{alpha_K} being the null vector.
#' @field beta is the vector of regression coefficients of component k,
#' the updates for each of the expert component parameters consist in analytically solving a weighted
#' Gaussian linear regression problem.
#' @field sigma2 The variances for the \emph{K} mixture component.
#' @field nu degrees of freedom
#' @export
ParamTMoE <- setRefClass(
  "ParamTMoE",
  fields = list(

    X = "numeric",
    Y = "numeric",
    n = "numeric",
    phiBeta = "list",
    phiAlpha = "list",

    K = "numeric", # Number of regimes
    p = "numeric", # Dimension of beta (order of polynomial regression)
    q = "numeric", # Dimension of w (order of logistic regression)
    df = "numeric", # Degree of freedom

    alpha = "matrix",
    beta = "matrix",
    sigma2 = "matrix",
    nu = "matrix"
  ),
  methods = list(
    initialize = function(X = numeric(), Y = numeric(1), K = 1, p = 3, q = 1) {

      X <<- X
      Y <<- Y
      n <<- length(Y)
      phiBeta <<- designmatrix(x = X, p = p)
      phiAlpha <<- designmatrix(x = X, p = q)

      K <<- K
      p <<- p
      q <<- q

      df <<- (q + 1) * (K - 1) + (p + 1) * K + K

      alpha <<- matrix(0, q + 1, K - 1)
      beta <<- matrix(NA, p + 1, K)
      sigma2 <<- matrix(NA, 1, K)
      nu <<- matrix(NA, K)
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

      # Intitialization of the degrees of freedom
      nu <<- 50 * rand(1, K)

    },

    MStep = function(statTMoE, verbose_IRLS) {

      res_irls <- IRLS(phiAlpha$XBeta, statTMoE$tik, ones(nrow(statTMoE$tik), 1), alpha, verbose_IRLS)
      statTMoE$piik <- res_irls$piik
      reg_irls <- res_irls$reg_irls

      alpha <<- res_irls$W

      for (k in 1:K) {

        # Update the regression coefficients
        Xbeta <- phiBeta$XBeta * (matrix(sqrt(statTMoE$tik[, k] * statTMoE$Wik[, k])) %*% ones(1, p + 1))
        yk <- Y * sqrt(statTMoE$tik[, k] * statTMoE$Wik[, k])

        beta[, k] <<- solve((t(Xbeta) %*% Xbeta)) %*% (t(Xbeta) %*% yk)

        # Update the variances sigma2k
        sigma2[k] <<- sum(statTMoE$tik[, k] * statTMoE$Wik[, k] * ((Y - phiBeta$XBeta %*% beta[, k]) ^ 2)) / sum(statTMoE$tik[, k])

        # If ECM (use an additional E-Step with the updated betak and sigma2k
        dik <- (Y - phiBeta$XBeta %*% beta[, k]) / sqrt(sigma2[k])

        # Update the degrees of freedom
        try(nu[k] <<- pracma::fzero(f <- function(nuk) {
          return(
            -psigamma(nuk / 2) + log(nuk / 2) + 1 + (1 / sum(statTMoE$tik[, k])) * sum(statTMoE$tik[, k] * (log(statTMoE$Wik[, k]) - statTMoE$Wik[, k]))
            + psigamma((nuk[k] + 1) / 2) - log((nuk[k] + 1) / 2)
          )
        }, nu[k])$x, silent = TRUE)

      }

      return(reg_irls)
    }
  )
)
