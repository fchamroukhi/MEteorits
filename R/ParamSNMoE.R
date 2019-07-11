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

    K = "numeric",
    # number of regimes
    p = "numeric",
    # dimension of beta (order of polynomial regression)
    q = "numeric",
    # dimension of w (order of logistic regression)
    nu = "numeric", # degree of freedom

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
      alpha <<- matrix(runif((q + 1) * (K - 1)), nrow = q + 1, ncol = K - 1) #initialisation al??atoire du vercteur param???tre du IRLS

      #Initialise the regression parameters (coeffecients and variances):
      if (segmental == FALSE) {
        Zik <- zeros(fData$n, K)

        klas <- floor(K * matrix(runif(fData$n), fData$n)) + 1

        Zik[klas %*% ones(1, K) == ones(fData$n, 1) %*% seq(K)] <- 1

        Tauik <- Zik


        #beta <<- matrix(0, modelRHLP$p + 1, modelRHLP$K)
        #sigma <<- matrix(0, modelRHLP$K)

        for (k in 1:K) {
          Xk <- phiBeta$XBeta * (sqrt(Tauik[, k] %*% ones(1, p + 1)))
          yk <- fData$Y * sqrt(Tauik[, k])

          beta[, k] <<- solve(t(Xk) %*% Xk) %*% t(Xk) %*% yk

          sigma[k] <<- sum(Tauik[, k] * ((fData$Y - phiBeta$XBeta %*% beta[, k]) ^ 2)) / sum(Tauik[, k])
        }
      }
      else{
        #segmental : segment uniformly the data and estimate the parameters
        nk <- round(fData$n / K) - 1

        for (k in 1:K) {
          i <- (k - 1) * nk + 1
          j <- (k * nk)
          yk <- matrix(fData$Y[i:j])
          Xk <- phiBeta$XBeta[i:j,]

          beta[, k] <<- solve(t(Xk) %*% Xk) %*% (t(Xk) %*% yk)

          muk <- Xk %*% beta[, k]

          sigma[k] <<- t(yk - muk) %*% (yk - muk) / length(yk)
        }
      }

      if (try_EM == 1) {
        alpha <<- zeros(q + 1, K - 1)
      }

      # Initialize the skewness parameter Lambdak (by equivalence delta)
      delta <<- -1 + 2 * rand(1, K)

      lambda <<- delta / sqrt(1 - delta ^ 2)
    },

    MStep = function(statSNMoE, verbose_IRLS) {
      # M-Step
      res_irls <- IRLS(phiAlpha$XBeta, statSNMoE$tik, ones(nrow(statSNMoE$tik), 1), alpha, verbose_IRLS)
      statSNMoE$piik <- res_irls$piik
      reg_irls <- res_irls$reg_irls

      alpha <<- res_irls$W

      for (k in 1:K) {
        #update the regression coefficients

        tauik_Xbeta <- (statSNMoE$tik[, k] %*% ones(1, p + 1)) * phiBeta$XBeta
        beta[, k] <<- solve((t(tauik_Xbeta) %*% phiAlpha$XBeta)) %*% (t(tauik_Xbeta) %*% (fData$Y - delta[k] * statSNMoE$E1ik[, k]))

        # update the variances sigma2k

        sigma[k] <<- sum(statSNMoE$tik[, k] * ((fData$Y - phiBeta$XBeta %*% beta[, k]) ^ 2 - 2 * delta[k] * statSNMoE$E1ik[, k] * (fData$Y - phiBeta$XBeta %*% beta[, k]) + statSNMoE$E2ik[, k])) / (2 * (1 - delta[k] ^ 2) * sum(statSNMoE$tik[, k]))

        # update the deltak (the skewness parameter)
        delta[k] <<- uniroot(f <- function(dlt) {
          sigma[k] * dlt * (1 - dlt ^ 2) * sum(statSNMoE$tik[, k]) + (1 + dlt ^ 2) * sum(statSNMoE$tik[, k] * (fData$Y - phiBeta$XBeta %*% beta[, k]) * statSNMoE$E1ik[, k])
          - dlt * sum(statSNMoE$tik[, k] * (statSNMoE$E2ik[, k] + (fData$Y - phiBeta$XBeta %*% beta[, k]) ^ 2))
        }, c(-1, 1))$root


        lambda[k] <<- delta[k] / sqrt(1 - delta[k] ^ 2)

      }

      return(reg_irls)
    }
  )
)
