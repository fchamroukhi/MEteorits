#' A Reference Class which contains parameters of a TMoE model.
#'
#' ParamTMoE contains all the parameters of a TMoE model.
#'
#' @field fData [FData][FData] object representing the sample.
#' @field K The number of mixture components.
#' @field p The order of the polynomial regression.
#' @field q The dimension of the logistic regression. For the purpose of
#' segmentation, it must be set to 1.
#' @field nu degree of freedom
#' @field alpha is the parameter vector of the logistic model with \eqn{alpha_K} being the null vector.
#' @field beta is the vector of regression coefficients of component k,
#' the updates for each of the expert component parameters consist in analytically solving a weighted
#' Gaussian linear regression problem.
#' @field sigma The variances for the \emph{K} mixture component.
#' @field nuk degrees of freedom
#' @seealso [FData]
#' @export
ParamTMoE <- setRefClass(
  "ParamTMoE",
  fields = list(
    fData = "FData",

    phiBeta = "list",
    phiAlpha = "list",
    K = "numeric", # Number of regimes
    p = "numeric", # Dimension of beta (order of polynomial regression)
    q = "numeric", # Dimension of w (order of logistic regression)
    nu = "numeric", # Degree of freedom

    alpha = "matrix",
    beta = "matrix",
    sigma = "matrix",
    nuk = "matrix"
  ),
  methods = list(
    initialize = function(fData = FData(numeric(1), matrix(1)), K = 1, p = 3, q = 1) {
      fData <<- fData

      phiBeta <<- designmatrix(x = fData$X, p = p)
      phiAlpha <<- designmatrix(x = fData$X, p = q)

      K <<- K
      p <<- p
      q <<- q

      nu <<- (p + q + 3) * K - (q + 1)

      alpha <<- matrix(0, q + 1, K - 1)
      beta <<- matrix(NA, p + 1, K)
      sigma <<- matrix(NA, 1, K)
      nuk <<- matrix(NA, K)
    },

    initParam = function(try_EM, segmental = FALSE) {
      "Method to initialize parameters \\code{alpha}, \\code{beta} and
      \\code{sigma}."

      # Initialize the regression parameters (coefficents and variances):
      if (!segmental) {

        klas <- sample(1:K, fData$n, replace = TRUE)

        for (k in 1:K) {

          Xk <- phiBeta$XBeta[klas == k,]
          yk <- fData$Y[klas == k]

          beta[, k] <<- solve(t(Xk) %*% Xk) %*% t(Xk) %*% yk

          sigma[k] <<- sum((yk - Xk %*% beta[, k]) ^ 2) / length(yk)
        }
      } else {# Segmental : segment uniformly the data and estimate the parameters

        nk <- round(fData$n / K) - 1

        klas <- rep.int(0, fData$n)

        for (k in 1:K) {
          i <- (k - 1) * nk + 1
          j <- (k * nk)
          yk <- matrix(fData$Y[i:j])
          Xk <- phiBeta$XBeta[i:j, ]

          beta[, k] <<- solve(t(Xk) %*% Xk, tol = 0) %*% (t(Xk) %*% yk)

          muk <- Xk %*% beta[, k, drop = FALSE]

          sigma[k] <<- t(yk - muk) %*% (yk - muk) / length(yk)

          klas[i:j] <- k
        }
      }

      # Intialize the softmax parameters
      Z <- matrix(0, nrow = fData$n, ncol = K)
      Z[klas %*% ones(1, K) == ones(fData$n, 1) %*% seq(K)] <- 1
      tau <- Z
      res <- IRLS(phiAlpha$XBeta, tau, ones(nrow(tau), 1), alpha)
      alpha <<- res$W

      # Intitialization of the degrees of freedom
      nuk <<- 50 * rand(1, K)

    },

    MStep = function(statTMoE, verbose_IRLS) {

      res_irls <- IRLS(phiAlpha$XBeta, statTMoE$tik, ones(nrow(statTMoE$tik), 1), alpha, verbose_IRLS)
      statTMoE$piik <- res_irls$piik
      reg_irls <- res_irls$reg_irls

      alpha <<- res_irls$W

      for (k in 1:K) {

        # Update the regression coefficients
        Xbeta <- phiBeta$XBeta * (matrix(sqrt(statTMoE$tik[, k] * statTMoE$Wik[, k])) %*% ones(1, p + 1))
        yk <- fData$Y * sqrt(statTMoE$tik[, k] * statTMoE$Wik[, k])

        beta[, k] <<- solve((t(Xbeta) %*% Xbeta)) %*% (t(Xbeta) %*% yk)

        # Update the variances sigma2k
        sigma[k] <<- sum(statTMoE$tik[, k] * statTMoE$Wik[, k] * ((fData$Y - phiBeta$XBeta %*% beta[, k]) ^ 2)) / sum(statTMoE$tik[, k])

        # If ECM (use an additional E-Step with the updated betak and sigma2k
        dik <- (fData$Y - phiBeta$XBeta %*% beta[, k]) / sqrt(sigma[k])

        # Update the degrees of freedom
        try(nuk[k] <<- pracma::fzero(f <- function(nu) {
          return(
            -psigamma(nu / 2) + log(nu / 2) + 1 + (1 / sum(statTMoE$tik[, k])) * sum(statTMoE$tik[, k] * (log(statTMoE$Wik[, k]) - statTMoE$Wik[, k]))
            + psigamma((nuk[k] + 1) / 2) - log((nuk[k] + 1) / 2)
          )
        }, nuk[k])$x, silent = TRUE)

      }

      return(reg_irls)
    }
  )
)
