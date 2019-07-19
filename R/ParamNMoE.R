#' A Reference Class which contains parameters of a NMoE model.
#'
#' ParamNMoE contains all the parameters of a NMoE model.
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
#' @field sigma The variances for the \emph{K} mixture components.
#' @field delta the skewness parameter lambda (by equivalence delta)
#' @seealso [FData]
#' @export
ParamNMoE <- setRefClass(
  "ParamNMoE",
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
    sigma = "matrix"
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
    },

    initParam = function(try_EM, segmental = FALSE) {
      alpha <<- matrix(runif((q + 1) * (K - 1)), nrow = q + 1, ncol = K - 1)  #random initialization of parameter vector of IRLS

      #Initialise the regression parameters (coeffecients and variances):
      if (segmental == FALSE) {
        Zik <- zeros(n, K)

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

    },

    MStep = function(statNMoE, verbose_IRLS) {
      # M-Step
      res_irls <- IRLS(phiAlpha$XBeta, statNMoE$tik, ones(nrow(statNMoE$tik), 1), alpha, verbose_IRLS)
      statNMoE$piik <- res_irls$piik
      reg_irls <- res_irls$reg_irls

      alpha <<- res_irls$W

      for (k in 1:K) {
        #update the regression coefficients

        Xbeta <- phiBeta$XBeta * sqrt(statNMoE$tik[,k] %*% ones(1, p + 1))
        yk <- fData$Y * sqrt(statNMoE$tik[,k])

        #update the regression coefficients
        beta[, k] <<- solve((t(Xbeta) %*% Xbeta)) %*% (t(Xbeta) %*% yk)

        # update the variances sigma2k
        sigma[k] <<- sum(statNMoE$tik[, k] * ((fData$Y - phiBeta$XBeta %*% beta[, k])^2)) / sum(statNMoE$tik[,k])

      }

      return(reg_irls)
    }
  )
)
