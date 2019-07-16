#' A Reference Class which contains parameters of a MRHLP model.
#'
#' ParamMRHLP contains all the parameters of a MRHLP model.
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
#' @field nuk degrees of freedom
#' @seealso [FData]
#' @export
ParamStMoE <- setRefClass(
  "ParamStMoE",
  fields = list(
    fData = "FData",
    phiBeta = "list",
    phiAlpha = "list",

    K = "numeric",
    # number of components
    p = "numeric",
    # dimension of beta (order of polynomial regression)
    q = "numeric",
    # dimension of w (order of logistic regression)
    nu = "numeric", # degree of freedom

    alpha = "matrix",
    beta = "matrix",
    sigma = "matrix",
    lambda = "matrix",
    delta = "matrix",
    nuk = "matrix"
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
      "Method to initialize parameters \\code{alpha}, \\code{beta} and
      \\code{sigma}."

      alpha <<- matrix(runif((q + 1) * (K - 1)), nrow = q + 1, ncol = K - 1)  #random initialization of parameter vector of IRLS

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
        alpha <<- rand(q + 1, K - 1)
      }

      # Initialize the skewness parameter Lambdak (by equivalence delta)
      delta <<- -0.9 + 1.8 * rand(1, K)

      lambda <<- delta / sqrt(1 - delta ^ 2)

      # Intitialization of the degrees of freedm
      nuk <<- 1 + 5 * rand(1, K)
    },

    MStep = function(statStMoE, verbose_IRLS) {
      "Method used in the EM algorithm to learn the parameters of the StMoE model
      based on statistics provided by \\code{statStMoE}."
      # M-Step
      res_irls <- IRLS(phiAlpha$XBeta, statStMoE$tik, ones(nrow(statStMoE$tik), 1), alpha, verbose_IRLS)
      # statStMoE$piik <- res_irls$piik
      reg_irls <- res_irls$reg_irls

      alpha <<- res_irls$W

      for (k in 1:K) {
        #update the regression coefficients
        TauikWik <- (statStMoE$tik[,k] * statStMoE$wik[,k]) %*% ones(1, p+1)
        TauikX <- phiBeta$XBeta * (statStMoE$tik[,k] %*% ones(1, p+1))
        betak <- solve((t(TauikWik * phiBeta$XBeta) %*% phiAlpha$XBeta)) %*% (t(TauikX) %*% ( (statStMoE$wik[,k] * fData$Y) - (delta[k] * statStMoE$E1ik[ ,k]) ))

        beta[,k] <<- betak;
        # update the variances sigma2k

        sigma[k] <<- sum(statStMoE$tik[, k]*(statStMoE$wik[,k] * ((fData$Y-phiBeta$XBeta%*%betak)^2) - 2 * delta[k] * statStMoE$E1ik[,k] * (fData$Y - phiBeta$XBeta %*% betak) + statStMoE$E2ik[,k]))/(2*(1-delta[k]^2) * sum(statStMoE$tik[,k]))

        sigmak <- sqrt(sigma[k])

        # update the deltak (the skewness parameter)
        delta[k] <<- uniroot(f <- function(dlt) {
          return(dlt*(1-dlt^2)*sum(statStMoE$tik[, k])
          + (1+ dlt^2)*sum(statStMoE$tik[, k] * statStMoE$dik[,k]*statStMoE$E1ik[,k]/sigmak)
          - dlt * sum(statStMoE$tik[, k] * (statStMoE$wik[,k] * (statStMoE$dik[,k]^2) + statStMoE$E2ik[,k]/(sigmak^2))))
        }, c(-1, 1))$root


        lambda[k] <<- delta[k] / sqrt(1 - delta[k] ^ 2)


        nuk[k] <<- uniroot(f <- function(nnu) {
          return(- psigamma((nnu)/2) + log((nnu)/2) + 1 + sum(statStMoE$tik[,k] * (statStMoE$E3ik[,k] - statStMoE$wik[,k]))/sum(statStMoE$tik[,k]))
        }, c(0.1, 200))$root
      }

      return(reg_irls)
    }
  )
)
