#' emStMoE implements the ECM algorithm to fit a StMoE model.
#'
#' emStMoE implements the maximum-likelihood parameter estimation of a StMoE
#' model by the Expectation Conditional Maximization (ECM) algorithm.
#'
#' @details emStMoE function function implements the ECM algorithm for the StMoE model. This functions starts
#' with an initialization of the parameters done by the method `initParam` of
#' the class [ParamStMoE][ParamStMoE], then it alternates between a E-Step
#' (method of the class [StatStMoE][StatStMoE]) and a CM-Step (method of the class
#' [ParamStMoE][ParamStMoE]) until convergence (until the absolute difference of
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
#' @return Th ECM algorithm returns an object of class [ModelStMoE][ModelStMoE].
#' @seealso [ModelStMoE], [ParamStMoE], [StatStMoE]
#' @export
emStMoE <- function(X, Y, K, p = 3, q = 1, n_tries = 1, max_iter = 1500, threshold = 1e-6, verbose = FALSE, verbose_IRLS = FALSE) {

    fData <- FData(X, Y)

    top <- 0
    try_EM <- 0
    best_loglik <- -Inf

    while (try_EM < n_tries) {
      try_EM <- try_EM + 1
      message("EM try nr ", try_EM)

      # Initialization
      param <- ParamStMoE$new(fData = fData, K = K, p = p, q = q)
      param$initParam(try_EM, segmental = FALSE)



      iter <- 0
      converge <- FALSE
      prev_loglik <- -Inf

      stat <- StatStMoE(paramStMoE = param)
      stat$univStMoEpdf(param)

      while (!converge && (iter <= max_iter)) {
        stat$EStep(param)

        reg_irls <- param$MStep(stat, verbose_IRLS)

        stat$computeLikelihood(reg_irls)
        # End of EM

        iter <- iter + 1
        if (verbose) {
          message("EM : Iteration : ", iter," log-likelihood : "  , stat$log_lik)
        }
        if (prev_loglik - stat$log_lik > 1e-5) {
          message("!!!!! EM log-likelihood is decreasing from ", prev_loglik, "to ", stat$log_lik)
          top <- top + 1
          if (top > 20)
            break
        }

        # test of convergence
        converge <- abs((stat$log_lik - prev_loglik) / prev_loglik) <= threshold
        if (is.na(converge)) {
          converge <- FALSE
        } # Basically for the first iteration when prev_loglik is -Inf

        prev_loglik <- stat$log_lik
        stat$stored_loglik <- c(stat$stored_loglik, stat$log_lik)
      }# End of and EM loop

      # end of computation of all estimates (param and stat)

      if (stat$log_lik > best_loglik) {
        statSolution <- stat$copy()
        paramSolution <- param$copy()

        best_loglik <- stat$log_lik
      }
      if (n_tries > 1) {
        message("max value: ", stat$log_lik)
      }
    }

    # Computation of z_ik the hard partition of the data and the class labels klas
    statSolution$MAP()

    if (n_tries > 1) {
      message("max value: ", statSolution$log_lik)
    }


    # End of the computation of statSolution
    statSolution$computeStats(paramSolution)

    return(ModelStMoE(param = paramSolution, stat = statSolution))

  }
