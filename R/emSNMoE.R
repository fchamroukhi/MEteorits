#' emSNMoE implements the ECM algorithm to fit a SNMoE model.
#'
#' emSNMoE implements the maximum-likelihood parameter estimation of a SNMoE
#' model by the Expectation Conditional Maximization (ECM) algorithm.
#'
#' @details emSNMoE function function implements the ECM algorithm for the SNMoE model. This functions starts
#' with an initialization of the parameters done by the method `initParam` of
#' the class [ParamSNMoE][ParamSNMoE], then it alternates between a E-Step
#' (method of the class [StatSNMoE][StatSNMoE]) and a CM-Step (method of the class
#' [ParamSNMoE][ParamSNMoE]) until convergence (until the absolute difference of
#' log-likelihood between two steps of the ECM algorithm is less than the
#' `threshold` parameter).
#'
#' @param X Numeric vector of length \emph{n} representing the covariates/inputs
#'   \eqn{x_{1},\dots,x_{m}}.
#' @param Y Numeric vector of length \emph{n} representing the observed
#'   response/output \eqn{y_{1},\dots,y_{m}}.
#' @param K The number of expert components.
#' @param p The order of the polynomial regression for the expert regressors network.
#' @param q The dimension of the logistic regression for the gating network. For the purpose of
#' segmentation, it must be set to 1.
#' @param n_tries Number of times ECM algorithm will be launched with different initializations.
#' The solution providing the highest log-likelihood will be returned.
#'
#' @param max_iter The maximum number of iterations for the ECM algorithm.
#' @param threshold A numeric value specifying the threshold for the relative
#'  difference of log-likelihood between two steps  of the ECM as stopping
#'  criteria.
#' @param verbose A logical value indicating whether values of the
#' log-likelihood should be printed during ECM iterations.
#' @param verbose_IRLS A logical value indicating whether values of the
#' criterion optimized by IRLS should be printed at each step of the ECM
#' algorithm.
#' @return Th ECM algorithm returns an object of class [ModelSNMoE][ModelSNMoE].
#' @seealso [ModelSNMoE], [ParamSNMoE], [StatSNMoE]
#' @export
emSNMoE <- function(X, Y, K, p = 3, q = 1, n_tries = 1, max_iter = 1500, threshold = 1e-6, verbose = FALSE, verbose_IRLS = FALSE) {

  fData <- FData(X, Y)

  top <- 0
  try_EM <- 0
  best_loglik <- -Inf

  while (try_EM < n_tries) {

    try_EM <- try_EM + 1

    if (n_tries > 1 && verbose) {
      message("EM try number: ", try_EM, "\n")
    }

    # Initialization
    param <- ParamSNMoE(fData = fData, K = K, p = p, q = q)
    param$initParam(try_EM, segmental = TRUE)

    iter <- 0
    converge <- FALSE
    prev_loglik <- -Inf

    stat <- StatSNMoE(paramSNMoE = param)

    while (!converge && (iter <= max_iter)) {
      stat$EStep(param)

      reg_irls <- param$MStep(stat, verbose_IRLS)

      stat$computeLikelihood(reg_irls)

      iter <- iter + 1
      if (verbose) {
        message("EM - SNMoE: Iteration: ", iter, " | log-likelihood: "  , stat$log_lik)
      }

      if (prev_loglik - stat$log_lik > 1e-5) {
        if (verbose) {
          warning("EM log-likelihood is decreasing from ", prev_loglik, "to ", stat$log_lik, "!")
        }
        top <- top + 1
        if (top > 20)
          break
      }

      # Test of convergence
      converge <- abs((stat$log_lik - prev_loglik) / prev_loglik) <= threshold

      if (is.na(converge)) {
        converge <- FALSE
      } # Basically for the first iteration when prev_loglik is Inf

      prev_loglik <- stat$log_lik
      stat$stored_loglik <- c(stat$stored_loglik, stat$log_lik)
    }# End of an EM loop

    if (stat$log_lik > best_loglik) {
      statSolution <- stat$copy()
      paramSolution <- param$copy()

      best_loglik <- stat$log_lik
    }

    if (n_tries > 1 && verbose) {
      message("Max value of the log-likelihood: ", stat$log_lik, "\n\n")
    }
  }

  # Computation of z_ik the hard partition of the data and the class labels klas
  statSolution$MAP()

  if (n_tries > 1 && verbose) {
    message("Max value of the log-likelihood: ", statSolution$log_lik, "\n")
  }

  statSolution$computeStats(paramSolution)

  return(ModelSNMoE(param = paramSolution, stat = statSolution))
}
