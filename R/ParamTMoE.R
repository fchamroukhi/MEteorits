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
#' @field delta the skewness parameter lambda (by equivalence delta)
#' @seealso [FData]
#' @export
ParamTMoE <- setRefClass(
  "ParamTMoE",
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
    delta = "matrix"
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
      delta <<- matrix(NA, K)
    },

    initParam = function(try_EM, segmental = FALSE) {
      alpha <<- matrix(runif((q + 1) * (K - 1)), nrow = q + 1, ncol = K - 1) #random initialization of parameter vector of IRLS

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

          muk <- Xk %*% beta[, k, drop = FALSE]

          sigma[k] <<- t(yk - muk) %*% (yk - muk) / length(yk)
        }
      }

      if (try_EM == 1) {
        alpha <<- zeros(q + 1, K - 1)
      }

      # Initialize the skewness parameter Lambdak (by equivalence delta)
      delta <<- 50 * rand(1, K)

    },

    MStep = function(statTMoE, verbose_IRLS) {
      # M-Step
      res_irls <- IRLS(phiAlpha$XBeta, statTMoE$tik, ones(nrow(statTMoE$tik), 1), alpha, verbose_IRLS)
      statTMoE$piik <- res_irls$piik
      reg_irls <- res_irls$reg_irls

      alpha <<- res_irls$W

      for (k in 1:K) {
        #update the regression coefficients

        Xbeta <- phiBeta$XBeta * (matrix( sqrt(statTMoE$tik[,k] * statTMoE$Wik[,k] )) %*% ones(1, p + 1))
        yk <- fData$Y * sqrt(statTMoE$tik[,k] * statTMoE$Wik[,k])

        #update the regression coefficients
        beta[, k] <<- solve((t(Xbeta) %*% Xbeta)) %*% (t(Xbeta) %*% yk)

        # update the variances sigma2k
        sigma[k] <<- sum(statTMoE$tik[, k] * statTMoE$Wik[,k] * ((fData$Y - phiBeta$XBeta %*% beta[, k])^2)) / sum(statTMoE$tik[,k])

        # if ECM (use an additional E-Step with the updatated betak and sigma2k
        dik <- (fData$Y - phiBeta$XBeta %*% beta[, k]) / sqrt(sigma[k])


        # update the deltak (the skewness parameter)
        delta[k] <<- pracma::fzero(f <- function(dlt) {
          return(-psigamma(dlt/2) + log(dlt/2) + 1 + (1 / sum(statTMoE$tik[, k])) * sum(statTMoE$tik[, k] * (log(statTMoE$Wik[,k]) - statTMoE$Wik[,k]))
                 + psigamma((delta[k] + 1)/2) - log((delta[k] + 1)/2))
        }, delta[k])$x

      }

      return(reg_irls)
    }
  )
)
