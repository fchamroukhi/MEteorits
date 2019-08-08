#' A Reference Class which contains parameters of a SNMoE model.
#'
#' ParamSNMoE contains all the parameters of a SNMoE model.
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
#' @field lambda skewness parameter
#' @field delta the skewness parameter lambda (by equivalence delta)
#' @seealso [FData]
#' @export
ParamSNMoE <- setRefClass(
  "ParamSNMoE",
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
    lambda = "matrix",
    delta = "matrix"
  ),
  methods = list(
    initialize = function(fData = FData(numeric(1), matrix(1)), K = 1, p = 3, q = 1) {
      fData <<- fData

      phiBeta <<- designmatrix(x = fData$X, p = p)
      phiAlpha <<- designmatrix(x = fData$X, p = q)

      nu <<- (p + q + 3) * K - (q + 1)
      K <<- K
      p <<- p
      q <<- q

      alpha <<- matrix(0, q + 1, K - 1)
      beta <<- matrix(NA, p + 1, K)
      sigma <<- matrix(NA, 1, K)
      lambda <<- matrix(NA, K)
      delta <<- matrix(NA, K)
    },

    initParam = function(try_EM, segmental = FALSE) {

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

          beta[, k] <<- solve(t(Xk) %*% Xk) %*% (t(Xk) %*% yk)

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
      alpha <- res$W

      # Initialize the skewness parameter Lambdak (by equivalence delta)
      lambda <<- -1 + 2 * rand(1, K)
      delta <<- lambda / sqrt(1 + lambda ^ 2)

      # # Possible initialization using moments
      # ybar <- mean(fData$Y)
      # a1 <- sqrt(2 / pi)
      # b1 <- (4 / pi - 1) * a1
      # m2 <- (1 / (fData$n - 1)) * sum((fData$Y - ybar) ^ 2)
      # m3 <- (1 / (fData$n - 1)) * sum(abs(fData$Y - ybar) ^ 3)
      # DeltakAll <- (a1 ^ 2 + m2 * (b1 / m3) ^ (2 / 3)) ^ (0.5)
      # lambda <<- DeltakAll * ones(1, K)
      # delta <<- lambda / sqrt(1 + lambda ^ 2)
    },

    MStep = function(statSNMoE, verbose_IRLS) {

      res_irls <- IRLS(phiAlpha$XBeta, statSNMoE$tik, ones(nrow(statSNMoE$tik), 1), alpha, verbose_IRLS)
      statSNMoE$piik <- res_irls$piik
      reg_irls <- res_irls$reg_irls

      alpha <<- res_irls$W

      for (k in 1:K) {

        # Update the regression coefficients
        tauik_Xbeta <- (statSNMoE$tik[, k] %*% ones(1, p + 1)) * phiBeta$XBeta
        beta[, k] <<- solve((t(tauik_Xbeta) %*% phiBeta$XBeta)) %*% (t(tauik_Xbeta) %*% (fData$Y - delta[k] * statSNMoE$E1ik[, k]))

        # Update the variances sigma2k
        sigma[k] <<- sum(statSNMoE$tik[, k] * ((fData$Y - phiBeta$XBeta %*% beta[, k]) ^ 2 - 2 * delta[k] * statSNMoE$E1ik[, k] * (fData$Y - phiBeta$XBeta %*% beta[, k]) + statSNMoE$E2ik[, k])) / (2 * (1 - delta[k] ^ 2) * sum(statSNMoE$tik[, k]))

        # Update the lambdak (the skewness parameter)
        try(lambda[k] <<- uniroot(f <- function(lmbda) {
          return(
            sigma[k] * (lmbda / sqrt(1 + lmbda ^ 2)) * (1 - (lmbda ^ 2 / (1 + lmbda ^ 2))) * sum(statSNMoE$tik[, k]) + (1 + (lmbda ^ 2 / (1 + lmbda ^ 2))) * sum(
              statSNMoE$tik[, k] * (fData$Y - phiBeta$XBeta %*% beta[, k]) * statSNMoE$E1ik[, k]
            )
            - (lmbda / sqrt(1 + lmbda ^ 2)) * sum(statSNMoE$tik[, k] * (
              statSNMoE$E2ik[, k] + (fData$Y - phiBeta$XBeta %*% beta[, k]) ^ 2
            ))
          )
        },
        interval = c(-100, 100),
        extendInt = "yes")$root,
        silent = TRUE)

        delta[k] <<- lambda[k] / sqrt(1 + lambda[k] ^ 2)

      }

      return(reg_irls)
    }
  )
)
