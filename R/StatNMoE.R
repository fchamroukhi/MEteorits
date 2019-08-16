#' A Reference Class which contains statistics of a NMoE model.
#'
#' StatNoE contains all the parameters of a [NMoE][ParamNMoE] model.
#'
#' @field piik Matrix of size \eqn{(n, K)} representing the probabilities
#'   \eqn{P(zi = k; W) = P(z_{ik} = 1; W)}{P(zi = k; W) = P(z_ik = 1; W)} of the
#'   latent variable \eqn{zi,\ i = 1,\dots,m}{zi, i = 1,\dots,n}.
#' @field z_ik Hard segmentation logical matrix of dimension \eqn{(n, K)}
#'   obtained by the Maximum a posteriori (MAP) rule: \eqn{z_{ik} = 1 \
#'   \textrm{if} \ z_{ik} = \textrm{arg} \ \textrm{max}_{k} \ P(z_i = k | Y, W,
#'   \beta);\ 0 \ \textrm{otherwise}}{z_ik = 1 if z_ik = arg max_k P(z_i = k |
#'   Y, W, \beta); 0 otherwise}, \eqn{k = 1,\dots,K}.
#' @field klas Column matrix of the labels issued from `z_ik`. Its elements are
#'   \eqn{klas(i) = k}, \eqn{k = 1,\dots,K}.
#' @field Wik Matrix of dimension \emph{(nm,K)}.
#' @field Ey_k Matrix of dimension \emph{(n,K)}.
#' @field Ey Column matrix of dimension \emph{n}.
#' @field Var_yk Column matrix of dimension \emph{K}.
#' @field Vary Column matrix of dimension \emph{n}.
#' @field log\_lik Numeric. Log-likelihood of the StMoE model.
#' @field com_loglik Numeric. Complete log-likelihood of the StMoE model.
#' @field stored_loglik Numeric vector. Stored values of the log-likelihood at
#'   each EM iteration.
#' @field BIC Numeric. Value of the BIC (Bayesian Information Criterion)
#'   criterion. The formula is \eqn{BIC = log\_lik - df \times \textrm{log}(n) /
#'   2}{BIC = log\_lik - df x log(n) / 2} with \emph{df} the degree of freedom
#'   of the StMoE model.
#' @field ICL Numeric. Value of the ICL (Integrated Completed Likelihood)
#'   criterion. The formula is \eqn{ICL = com\_loglik - df \times
#'   \textrm{log}(n) / 2}{ICL = com_loglik - df x log(n) / 2} with \emph{df} the
#'   degree of freedom of the StMoE model.
#' @field AIC Numeric. Value of the AIC (Akaike Information Criterion)
#'   criterion. The formula is \eqn{AIC = log\_lik - df}{AIC = log\_lik - df}.
#' @field log_piik_fik Matrix of size \eqn{(n, K)} giving the values of the
#'   logarithm of the joint probability \eqn{P(Y_{i}, \ zi = k)}{P(Yi, zi = k)},
#'   \eqn{i = 1,\dots,n}.
#' @field log_sum_piik_fik Column matrix of size \emph{n} giving the values of
#'   \eqn{\sum_{k = 1}^{K} \textrm{log} P(Y_{i}, \ zi = k)}{\sum_{k = 1}^{K} log
#'   P(Yi, zi = k)}, \eqn{i = 1,\dots,n}.
#' @field tik Matrix of size \eqn{(n, K)} giving the posterior probability that
#'   \eqn{Y_{i}}{Yi} originates from the \eqn{k}-th regression model \eqn{P(zi =
#'   k | Y, W, \beta)}.
#' @seealso [ParamNMoE]
#' @export
StatNMoE <- setRefClass(
  "StatNMoE",
  fields = list(
    piik = "matrix",
    z_ik = "matrix",
    klas = "matrix",
    Wik = "matrix",
    Ey_k = "matrix",
    Ey = "matrix",
    Var_yk = "matrix",
    Vary = "matrix",
    log_lik = "numeric",
    com_loglik = "numeric",
    stored_loglik = "numeric",
    BIC = "numeric",
    ICL = "numeric",
    AIC = "numeric",
    log_piik_fik = "matrix",
    log_sum_piik_fik = "matrix",
    tik = "matrix"
  ),
  methods = list(
    initialize = function(paramNMoE = ParamNMoE()) {
      piik <<- matrix(NA, paramNMoE$n, paramNMoE$K)
      z_ik <<- matrix(NA, paramNMoE$n, paramNMoE$K)
      klas <<- matrix(NA, paramNMoE$n, 1)
      Wik <<- matrix(0, paramNMoE$n, paramNMoE$K)
      Ey_k <<- matrix(NA, paramNMoE$n, paramNMoE$K)
      Ey <<- matrix(NA, paramNMoE$n, 1)
      Var_yk <<- matrix(NA, 1, paramNMoE$K)
      Vary <<- matrix(NA, paramNMoE$n, 1)
      log_lik <<- -Inf
      com_loglik <<- -Inf
      stored_loglik <<- numeric()
      BIC <<- -Inf
      ICL <<- -Inf
      AIC <<- -Inf
      log_piik_fik <<- matrix(0, paramNMoE$n, paramNMoE$K)
      log_sum_piik_fik <<- matrix(NA, paramNMoE$n, 1)
      tik <<- matrix(0, paramNMoE$n, paramNMoE$K)
    },

    MAP = function() {
      "
      calcule une partition d'un echantillon par la regle du Maximum A Posteriori ?? partir des probabilites a posteriori
      Entrees : post_probas , Matrice de dimensions [n x K] des probabibiltes a posteriori (matrice de la partition floue)
      n : taille de l'echantillon
      K : nombres de classes
      klas(i) = arg   max (post_probas(i,k)) , for all i=1,...,n
      1<=k<=K
      = arg   max  p(zi=k|xi;theta)
      1<=k<=K
      = arg   max  p(zi=k;theta)p(xi|zi=k;theta)/sum{l=1}^{K}p(zi=l;theta) p(xi|zi=l;theta)
      1<=k<=K
      Sorties : classes : vecteur collones contenant les classe (1:K)
      Z : Matrice de dimension [nxK] de la partition dure : ses elements sont zik, avec zik=1 si xi
      appartient ?? la classe k (au sens du MAP) et zero sinon.
      "
      N <- nrow(tik)
      K <- ncol(tik)
      ikmax <- max.col(tik)
      ikmax <- matrix(ikmax, ncol = 1)
      z_ik <<- ikmax %*% ones(1, K) == ones(N, 1) %*% (1:K) # partition_MAP
      klas <<- ones(N, 1)
      for (k in 1:K) {
        klas[z_ik[, k] == 1] <<- k
      }
    },

    computeLikelihood = function(reg_irls) {

      log_lik <<- sum(log_sum_piik_fik) + reg_irls

    },

    computeStats = function(paramNMoE) {

      # E[yi|xi,zi=k]
      Ey_k <<- paramNMoE$phiBeta$XBeta[1:paramNMoE$n,] %*% paramNMoE$beta

      # E[yi|xi]
      Ey <<- matrix(apply(piik * Ey_k, 1, sum))

      # Var[yi|xi,zi=k]
      Var_yk <<- paramNMoE$sigma2

      # Var[yi|xi]
      Vary <<- apply(piik * (Ey_k ^ 2 + ones(paramNMoE$n, 1) %*% Var_yk), 1, sum) - Ey ^ 2

      # BIC, AIC and ICL
      BIC <<- log_lik - (paramNMoE$df * log(paramNMoE$n) / 2)
      AIC <<- log_lik - paramNMoE$df

      # CL(theta) : complete-data loglikelihood
      zik_log_piik_fk <- z_ik * log_piik_fik
      sum_zik_log_fik <- apply(zik_log_piik_fk, 1, sum)
      com_loglik <<- sum(sum_zik_log_fik)

      ICL <<- com_loglik - (paramNMoE$df * log(paramNMoE$n) / 2)

    },

    EStep = function(paramNMoE) {

      piik <<- multinomialLogit(paramNMoE$alpha, paramNMoE$phiAlpha$XBeta, ones(paramNMoE$n, paramNMoE$K), ones(paramNMoE$n, 1))$piik
      piik_fik <- zeros(paramNMoE$n, paramNMoE$K)

      for (k in (1:paramNMoE$K)) {

        muk <- paramNMoE$phiBeta$XBeta %*% paramNMoE$beta[, k]
        sigma2k <- paramNMoE$sigma2[k]

        log_piik_fik[, k] <<- log(piik[, k]) - 0.5 * log(2 * pi) - 0.5 * log(sigma2k) - 0.5 * ((paramNMoE$Y - muk) ^ 2) / sigma2k
      }

      log_sum_piik_fik <<- matrix(log(rowSums(exp(log_piik_fik))))

      log_tik <- log_piik_fik - log_sum_piik_fik %*% ones(1, paramNMoE$K)
      ttik <- exp(log_tik)

      tik <<-  ttik / (rowSums(ttik) %*% ones(1, paramNMoE$K))
    }
  )
)
