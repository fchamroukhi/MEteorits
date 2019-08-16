#' A Reference Class which contains parameters of a NMoE model.
#'
#' ParamNMoE contains all the parameters of a NMoE model.
#'
#' @field fData [FData][FData] object representing the sample.
#' @field K The number of mixture components.
#' @field p The order of the polynomial regression.
#' @field q The dimension of the logistic regression. For the purpose of
#' segmentation, it must be set to 1.
#' @field df degree of freedom
#' @field alpha is the parameter vector of the logistic model with \eqn{alpha_K} being the null vector.
#' @field beta is the vector of regression coefficients of component k,
#' the updates for each of the expert component parameters consist in analytically solving a weighted
#' Gaussian linear regression problem.
#' @field sigma2 The variances for the \emph{K} mixture components.
#' @field delta the skewness parameter lambda (by equivalence delta)
#' @seealso [FData]
#' @export
ParamNMoE <- setRefClass(
  "ParamNMoE",
  fields = list(
    fData = "FData",
    phiBeta = "list",
    phiAlpha = "list",

    K = "numeric", # Number of regimes
    p = "numeric", # Dimension of beta (order of polynomial regression)
    q = "numeric", # Dimension of w (order of logistic regression)
    df = "numeric", # Degree of freedom

    alpha = "matrix",
    beta = "matrix",
    sigma2 = "matrix"
  ),
  methods = list(
    initialize = function(fData = FData(numeric(1), matrix(1)), K = 1, p = 3, q = 1) {
      fData <<- fData

      phiBeta <<- designmatrix(x = fData$X, p = p)
      phiAlpha <<- designmatrix(x = fData$X, p = q)

      K <<- K
      p <<- p
      q <<- q

      df <<- (q + 1) * (K - 1) + (p + 1) * K + K

      alpha <<- matrix(0, q + 1, K - 1)
      beta <<- matrix(NA, p + 1, K)
      sigma2 <<- matrix(NA, 1, K)
    },

    initParam = function(try_EM, segmental = FALSE) {

      # Initialize the regression parameters (coefficents and variances):
      if (!segmental) {

        klas <- sample(1:K, fData$n, replace = TRUE)

        for (k in 1:K) {

          Xk <- phiBeta$XBeta[klas == k,]
          yk <- fData$Y[klas == k]

          beta[, k] <<- solve(t(Xk) %*% Xk) %*% t(Xk) %*% yk

          sigma2[k] <<- sum((yk - Xk %*% beta[, k]) ^ 2) / length(yk)
        }
      } else {# Segmental : segment uniformly the data and estimate the parameters

        nk <- round(fData$n / K) - 1

        klas <- rep.int(0, fData$n)

        for (k in 1:K) {
          i <- (k - 1) * nk + 1
          j <- (k * nk)
          yk <- matrix(fData$Y[i:j])
          Xk <- phiBeta$XBeta[i:j, ]

          beta[, k] <<- solve(t(Xk) %*% Xk) %*% (t(Xk) %*% yk)

          muk <- Xk %*% beta[, k, drop = FALSE]

          sigma2[k] <<- t(yk - muk) %*% (yk - muk) / length(yk)

          klas[i:j] <- k
        }
      }

      # Intialize the softmax parameters
      Z <- matrix(0, nrow = fData$n, ncol = K)
      Z[klas %*% ones(1, K) == ones(fData$n, 1) %*% seq(K)] <- 1
      tau <- Z
      res <- IRLS(phiAlpha$XBeta, tau, ones(nrow(tau), 1), alpha)
      alpha <<- res$W

    },

    MStep = function(statNMoE, verbose_IRLS) {

      res_irls <- IRLS(phiAlpha$XBeta, statNMoE$tik, ones(nrow(statNMoE$tik), 1), alpha, verbose_IRLS)
      statNMoE$piik <- res_irls$piik
      reg_irls <- res_irls$reg_irls

      alpha <<- res_irls$W

      for (k in 1:K) {

        # Update the regression coefficients
        Xbeta <- phiBeta$XBeta * sqrt(statNMoE$tik[, k] %*% ones(1, p + 1))
        yk <- fData$Y * sqrt(statNMoE$tik[, k])

        beta[, k] <<- solve((t(Xbeta) %*% Xbeta)) %*% (t(Xbeta) %*% yk)

        # Update the variances sigma2k
        sigma2[k] <<- sum(statNMoE$tik[, k] * ((fData$Y - phiBeta$XBeta %*% beta[, k]) ^ 2)) / sum(statNMoE$tik[, k])

      }

      return(reg_irls)
    }
  )
)
