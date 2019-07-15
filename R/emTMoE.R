#' emTMoE is used to fit a TMoE model.
#'
#' emTMoE is used to fit a TMoE model. The estimation method is performed by
#' the Expectation-Maximization algorithm.
#'
#' @details emStMoE function is based on the EM algorithm. This functions starts
#' with an initialization of the parameters done by the method `initParam` of
#' the class [ParamTMoE][ParamTMoE], then it alternates between a E-Step
#' (method of the class [StatTMoE][StatTMoE]) and a M-Step (method of the class
#' [ParamTMoE][ParamTMoE]) until convergence (until the absolute difference of
#' log-likelihood between two steps of the EM algorithm is less than the
#' `threshold` parameter).
#'
#' @param X Numeric vector of length \emph{m} representing the covariates.
#' @param Y Matrix of size \eqn{(n, m)} representing \emph{n} functions of `X`
#' observed at points \eqn{1,\dots,m}.
#' @param K The number of mixture components.
#' @param p The order of the polynomial regression.
#' @param q The dimension of the logistic regression. For the purpose of
#' segmentation, it must be set to 1.
#' @param variance_type Numeric indicating if the model is homoskedastic
#' (`variance_type` = 1) or heteroskedastic (`variance_type` = 2).
#' @param n_tries Number of times EM algorithm will be launched.
#' The solution providing the highest log-likelihood will be returned.
#'
#' If `n_tries` > 1, then for the first pass, parameters are initialized
#' by uniformly segmenting the data into K segments, and for the next passes,
#' parameters are initialized by randomly segmenting the data into K contiguous
#'  segments.
#' @param max_iter The maximum number of iterations for the EM algorithm.
#' @param threshold A numeric value specifying the threshold for the relative
#'  difference of log-likelihood between two steps  of the EM as stopping
#'  criteria.
#' @param verbose A logical value indicating whether values of the
#' log-likelihood should be printed during EM iterations.
#' @param verbose_IRLS A logical value indicating whether values of the
#' criterion optimized by IRLS should be printed at each step of the EM
#' algorithm.
#' @return EM returns an object of class [ModelTMoE][ModelTMoE].
#' @seealso [ModelTMoE], [ParamTMoE], [StatTMoE]
#' @export
emTMoE <- function(X, Y, K, p = 3, q = 1, n_tries = 1, max_iter = 1500, threshold = 1e-6, verbose = FALSE, verbose_IRLS = FALSE) {

    fData <- FData(X, Y)

    top <- 0
    try_EM <- 0
    best_loglik <- -Inf

    while (try_EM < n_tries) {
      try_EM <- try_EM + 1
      message("EM try nr ", try_EM)

      # Initializations
      param <- ParamTMoE$new(fData = fData, K = K, p = p, q = q)
      param$initParam(try_EM, segmental = TRUE)



      iter <- 0
      converge <- FALSE
      prev_loglik <- -Inf

      stat <- StatTMoE(paramTMoE = param)

      while (!converge && (iter <= max_iter)) {
        stat$EStep(param)

        reg_irls <- param$MStep(stat, verbose_IRLS)

        stat$computeLikelihood(reg_irls)
        # FIN EM

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

        # TEST OF CONVERGENCE
        converge <- abs((stat$log_lik - prev_loglik) / prev_loglik) <= threshold
        if (is.na(converge)) {
          converge <- FALSE
        } # Basically for the first iteration when prev_loglik is Inf

        prev_loglik <- stat$log_lik
        stat$stored_loglik <- c(stat$stored_loglik, stat$log_lik)
      }# FIN EM LOOP

      # at this point we have computed param and stat that contains all the information

      if (stat$log_lik > best_loglik) {
        statSolution <- stat$copy()
        paramSolution <- param$copy()

        best_loglik <- stat$log_lik
      }
      if (n_tries > 1) {
        message("max value: ", stat$log_lik)
      }
    }

    # Computation of c_ig the hard partition of the curves and klas
    statSolution$MAP()

    if (n_tries > 1) {
      message("max value: ", statSolution$log_lik)
    }


    # FINISH computation of statSolution
    statSolution$computeStats(paramSolution)

    return(ModelTMoE(param = paramSolution, stat = statSolution))

  }
