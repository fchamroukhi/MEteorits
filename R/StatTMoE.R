#' A Reference Class which contains statistics of a TMoE model.
#'
#' StatTMoE contains all the parameters of a [TMoE][ParamTMoE] model.
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
#' @field log\_lik Numeric. Log-likelihood of the TMoE model.
#' @field com_loglik Numeric. Complete log-likelihood of the TMoE model.
#' @field stored_loglik Numeric vector. Stored values of the log-likelihood at
#'   each EM iteration.
#' @field BIC Numeric. Value of the BIC (Bayesian Information Criterion)
#'   criterion. The formula is \eqn{BIC = log\_lik - nu \times \textrm{log}(n) /
#'   2}{BIC = log\_lik - nu x log(n) / 2} with \emph{nu} the degree of freedom
#'   of the TMoE model.
#' @field ICL Numeric. Value of the ICL (Integrated Completed Likelihood)
#'   criterion. The formula is \eqn{ICL = com\_loglik - nu \times
#'   \textrm{log}(n) / 2}{ICL = com_loglik - nu x log(n) / 2} with \emph{nu} the
#'   degree of freedom of the TMoE model.
#' @field AIC Numeric. Value of the AIC (Akaike Information Criterion)
#'   criterion. The formula is \eqn{AIC = log\_lik - nu}{AIC = log\_lik - nu}.
#' @field log_piik_fik Matrix of size \eqn{(n, K)} giving the values of the
#'   logarithm of the joint probability \eqn{P(Y_{i}, \ zi = k)}{P(Yi, zi = k)},
#'   \eqn{i = 1,\dots,n}.
#' @field log_sum_piik_fik Column matrix of size \emph{n} giving the values of
#'   \eqn{\sum_{k = 1}^{K} \textrm{log} P(Y_{i}, \ zi = k)}{\sum_{k = 1}^{K} log
#'   P(Yi, zi = k)}, \eqn{i = 1,\dots,n}.
#' @field tik Matrix of size \eqn{(n, K)} giving the posterior probability that
#'   \eqn{Y_{i}}{Yi} originates from the \eqn{k}-th regression model \eqn{P(zi =
#'   k | Y, W, \beta)}.
#' @seealso [ParamTMoE], [FData]
#' @export
StatTMoE <- setRefClass(
  "StatTMoE",
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
    initialize = function(paramTMoE = ParamTMoE()) {
      piik <<- matrix(NA, paramTMoE$fData$n, paramTMoE$K)
      z_ik <<- matrix(NA, paramTMoE$fData$n, paramTMoE$K)
      klas <<- matrix(NA, paramTMoE$fData$n, 1)
      Wik <<- matrix(0, paramTMoE$fData$n * paramTMoE$fData$m, paramTMoE$K)
      Ey_k <<- matrix(NA, paramTMoE$fData$n, paramTMoE$K)
      Ey <<- matrix(NA, paramTMoE$fData$n, 1)
      Var_yk <<- matrix(NA, 1, paramTMoE$K)
      Vary <<- matrix(NA, paramTMoE$fData$n, 1)
      log_lik <<- -Inf
      com_loglik <<- -Inf
      stored_loglik <<- numeric()
      BIC <<- -Inf
      ICL <<- -Inf
      AIC <<- -Inf
      log_piik_fik <<- matrix(0, paramTMoE$fData$n, paramTMoE$K)
      log_sum_piik_fik <<- matrix(NA, paramTMoE$fData$n, 1)
      tik <<- matrix(0, paramTMoE$fData$n, paramTMoE$K)
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
      N <- nrow(piik)
      K <- ncol(piik)
      ikmax <- max.col(piik)
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

    computeStats = function(paramTMoE) {

      # E[yi|xi,zi=k]
      Ey_k <<- paramTMoE$phiBeta$XBeta[1:paramTMoE$fData$n,] %*% paramTMoE$beta

      # E[yi|xi]
      Ey <<- matrix(apply(piik * Ey_k, 1, sum))

      # Var[yi|xi,zi=k]
      Var_yk <<- paramTMoE$nuk / (paramTMoE$nuk - 2) * paramTMoE$sigma

      # Var[yi|xi]
      Vary <<- apply(piik * (Ey_k ^ 2 + ones(paramTMoE$fData$n, 1) %*% Var_yk), 1, sum) - Ey ^ 2

      # BIC, AIC and ICL
      BIC <<- log_lik - (paramTMoE$nu * log(paramTMoE$fData$n * paramTMoE$fData$m) / 2)
      AIC <<- log_lik - paramTMoE$nu

      # CL(theta) : complete-data loglikelihood
      zik_log_piik_fk <- (repmat(z_ik, paramTMoE$fData$m, 1)) * log_piik_fik
      sum_zik_log_fik <- apply(zik_log_piik_fk, 1, sum)
      com_loglik <<- sum(sum_zik_log_fik)

      ICL <<- com_loglik - (paramTMoE$nu * log(paramTMoE$fData$n * paramTMoE$fData$m) / 2)

    },

    EStep = function(paramTMoE) {

      piik <<- multinomialLogit(paramTMoE$alpha, paramTMoE$phiAlpha$XBeta, ones(paramTMoE$fData$n, paramTMoE$K), ones(paramTMoE$fData$n, 1))$piik

      piik_fik <- zeros(paramTMoE$fData$m * paramTMoE$fData$n, paramTMoE$K)

      for (k in (1:paramTMoE$K)) {

        muk <- paramTMoE$phiBeta$XBeta %*% paramTMoE$beta[, k]
        sigma2k <- paramTMoE$sigma[k]
        sigmak <- sqrt(sigma2k)
        dik <- (paramTMoE$fData$Y - muk) / sigmak

        nuk <- paramTMoE$nuk[k]
        Wik[, k] <<- (nuk + 1) / (nuk + dik ^ 2)

        # Weighted t linear expert likelihood
        piik_fik[, k] <- piik[, k] *  (1 / sigmak * dt((paramTMoE$fData$Y - muk) / sigmak, nuk)) #pdf('tlocationscale', y, muk, sigmak, nuk);
      }

      log_piik_fik <<- log(piik_fik)

      log_sum_piik_fik <<- matrix(log(rowSums(piik_fik)))

      tik <<- piik_fik / (rowSums(piik_fik) %*% ones(1, paramTMoE$K))
    }
  )
)
