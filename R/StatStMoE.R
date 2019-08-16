#' A Reference Class which contains statistics of a StMoE model.
#'
#' StatMRHLP contains all the parameters of a [StMoE][ParamStMoE] model.
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
#' @field Ey_k Matrix of dimension \emph{(n,K)}.
#' @field Ey Column matrix of dimension \emph{n}.
#' @field Var_yk Column matrix of dimension \emph{K}.
#' @field Var_y Column matrix of dimension \emph{n}.
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
#' @field wik To define.
#' @field dik To define.
#' @field stme_pdf skew-t mixture of experts density
#' @field E1ik To define.
#' @field E2ik To define.
#' @field E3ik To define.
#' @seealso [ParamStMoE]
#' @export
StatStMoE <- setRefClass(
  "StatStMoE",
  fields = list(
    piik = "matrix",
    z_ik = "matrix",
    klas = "matrix",
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
    tik = "matrix",
    wik = "matrix",
    dik = "matrix",
    stme_pdf = "matrix",
    E1ik = "matrix",
    E2ik = "matrix",
    E3ik = "matrix"
  ),
  methods = list(
    initialize = function(paramStMoE = ParamStMoE()) {
      piik <<- matrix(NA, paramStMoE$n, paramStMoE$K)
      z_ik <<- matrix(NA, paramStMoE$n, paramStMoE$K)
      klas <<- matrix(NA, paramStMoE$n, 1)
      Ey_k <<- matrix(NA, paramStMoE$n, paramStMoE$K)
      Ey <<- matrix(NA, paramStMoE$n, 1)
      Var_yk <<- matrix(NA, 1, paramStMoE$K)
      Vary <<- matrix(NA, paramStMoE$n, 1)
      log_lik <<- -Inf
      com_loglik <<- -Inf
      stored_loglik <<- numeric()
      BIC <<- -Inf
      ICL <<- -Inf
      AIC <<- -Inf
      log_piik_fik <<- matrix(0, paramStMoE$n, paramStMoE$K)
      log_sum_piik_fik <<- matrix(NA, paramStMoE$n, 1)
      tik <<- matrix(0, paramStMoE$n, paramStMoE$K)
      wik <<- matrix(0, paramStMoE$n, paramStMoE$K)
      dik <<- matrix(0, paramStMoE$n, paramStMoE$K)
      stme_pdf <<- matrix(0, paramStMoE$n, 1)
      E1ik <<- matrix(0, paramStMoE$n, paramStMoE$K)
      E2ik <<- matrix(0, paramStMoE$n, paramStMoE$K)
      E3ik <<- matrix(0, paramStMoE$n, paramStMoE$K)
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
      appartient et la classe k (au sens du MAP) et zero sinon.
      "
      N <- nrow(tik)
      K <- ncol(tik)
      ikmax <- max.col(tik)
      ikmax <- matrix(ikmax, ncol = 1)
      z_ik <<-
        ikmax %*% ones(1, K) == ones(N, 1) %*% (1:K) # partition_MAP
      klas <<- ones(N, 1)
      for (k in 1:K) {
        klas[z_ik[, k] == 1] <<- k
      }
    },

    computeLikelihood = function(reg_irls) {

      log_lik <<- sum(log_sum_piik_fik) + reg_irls

    },

    computeStats = function(paramStMoE) {

      Xi_nuk = sqrt(paramStMoE$nuk / pi) * (gamma(paramStMoE$nuk / 2 - 1 / 2)) / (gamma(paramStMoE$nuk / 2))

      # E[yi|xi,zi=k]
      Ey_k <<- paramStMoE$phiBeta$XBeta[1:paramStMoE$n,] %*% paramStMoE$beta + ones(paramStMoE$n, 1) %*% (paramStMoE$delta * sqrt(paramStMoE$sigma2) * Xi_nuk)

      # E[yi|xi]
      Ey <<- matrix(apply(piik * Ey_k, 1, sum))

      # Var[yi|xi,zi=k]
      Var_yk <<- (paramStMoE$nuk / (paramStMoE$nuk - 2) - (paramStMoE$delta ^ 2) * (Xi_nuk ^ 2)) * paramStMoE$sigma2

      # Var[yi|xi]
      Vary <<- apply(piik * (Ey_k ^ 2 + ones(paramStMoE$n, 1) %*% Var_yk), 1, sum) - Ey ^ 2

      # BIC, AIC and ICL
      BIC <<- log_lik - (paramStMoE$df * log(paramStMoE$n) / 2)
      AIC <<- log_lik - paramStMoE$df

      ## CL(theta) : complete-data loglikelihood
      zik_log_piik_fk <- z_ik * log_piik_fik
      sum_zik_log_fik <- apply(zik_log_piik_fk, 1, sum)
      com_loglik <<- sum(sum_zik_log_fik)

      ICL <<- com_loglik - (paramStMoE$df * log(paramStMoE$n) / 2)

    },

    univStMoEpdf = function(paramStMoE) {
      piik <<- multinomialLogit(paramStMoE$alpha, paramStMoE$phiAlpha$XBeta, ones(paramStMoE$n, paramStMoE$K), ones(paramStMoE$n, 1))$piik

      piik_fik <- zeros(paramStMoE$n, paramStMoE$K)
      dik <<- zeros(paramStMoE$n, paramStMoE$K)
      mik <- zeros(paramStMoE$n, paramStMoE$K)

      for (k in (1:paramStMoE$K)) {
        dik[, k] <<- (paramStMoE$Y - paramStMoE$phiBeta$XBeta %*% paramStMoE$beta[, k]) / sqrt(paramStMoE$sigma2[k])
        mik[, k] <- paramStMoE$lambda[k] %*% dik[, k] * sqrt(paramStMoE$nuk[k] + 1) / (paramStMoE$nuk[k] + dik[, k] ^ 2)
        piik_fik[, k] <- piik[, k] * (2 / sqrt(paramStMoE$sigma2[k])) * dt(dik[, k], paramStMoE$nuk[k]) * pt(mik[, k], paramStMoE$nuk[k] + 1)
      }

      stme_pdf <<- matrix(rowSums(piik_fik)) # Skew-t mixture of experts density
    },

    EStep = function(paramStMoE, calcTau = FALSE, calcE1 = FALSE, calcE2 = FALSE, calcE3 = FALSE) {
      "Method used in the EM algorithm to update statistics based on parameters
      provided by \\code{paramStMoE} (prior and posterior probabilities)."

      if (calcTau) {

        piik <<- multinomialLogit(paramStMoE$alpha, paramStMoE$phiAlpha$XBeta, ones(paramStMoE$n, paramStMoE$K), ones(paramStMoE$n, 1))$piik
        piik_fik <- zeros(paramStMoE$n, paramStMoE$K)
      }

      dik <<- zeros(paramStMoE$n, paramStMoE$K)
      mik <- zeros(paramStMoE$n, paramStMoE$K)
      wik <<- zeros(paramStMoE$n, paramStMoE$K)
      Integgtx <- zeros(paramStMoE$n, paramStMoE$K)

      for (k in (1:paramStMoE$K)) {

        fx = function(x) {
          return((psigamma((paramStMoE$nuk[k] + 2) / 2) - psigamma((paramStMoE$nuk[k] + 1) / 2) + log(1 + (x ^ 2) / (paramStMoE$nuk[k])) + ((paramStMoE$nuk[k] + 1) * x ^ 2 - paramStMoE$nuk[k] - 1) / ((paramStMoE$nuk[k] + 1) * (paramStMoE$nuk[k] + 1 + x ^ 2))) * dt(x, paramStMoE$nuk[k] + 1))
        }


        muk <- paramStMoE$phiBeta$XBeta %*% paramStMoE$beta[, k]
        sigmak <- sqrt(paramStMoE$sigma2[k])
        deltak <- paramStMoE$delta[k]


        dik[, k] <<- (paramStMoE$Y - muk) / sigmak
        mik[, k] <- paramStMoE$lambda[k] %*% dik[, k] * sqrt((paramStMoE$nuk[k] + 1) / (paramStMoE$nuk[k] + dik[, k] ^ 2))

        # E[Wi|yi,zik=1]
        wik[, k] <<- ((paramStMoE$nuk[k] + 1) / (paramStMoE$nuk[k] + dik[, k] ^ 2)) * pt(mik[, k] * sqrt((paramStMoE$nuk[k] + 3) / (paramStMoE$nuk[k] + 1)), paramStMoE$nuk[k] + 3) / pt(mik[, k], paramStMoE$nuk[k] + 1)


        if (calcE1) {
          univStMoEpdf(paramStMoE)
          # E[Wi Ui |yi,zik=1]
          E1ik[, k] <<- deltak * abs(paramStMoE$Y - muk) * wik[, k] +
            (sqrt(1 - deltak ^ 2) / (pi * stme_pdf)) * ((dik[, k] ^ 2 / (paramStMoE$nuk[k] * (1 - deltak ^ 2)) + 1) ^ (-(paramStMoE$nuk[k] / 2 + 1)))
        }

        if (calcE2) {
          E2ik[, k] <<- deltak ^ 2 * ((paramStMoE$Y - muk) ^ 2) * wik[, k] +
            (1 - deltak ^ 2) * sigmak ^ 2 + ((deltak * (paramStMoE$Y - muk) * sqrt(1 - deltak ^ 2)) / (pi * stme_pdf)) * (((dik[, k] ^ 2) / (paramStMoE$nuk[k] * (1 - deltak ^ 2)) + 1) ^ (-(paramStMoE$nuk[k] / 2 + 1)))
        }

        if (calcE3) {
          Integgtx[, k] <- sapply(mik[, k], function(x) try(integrate(f = fx, lower = -Inf, upper = x)$value, silent = TRUE))
          E3ik[, k] <<- wik[, k] - log((paramStMoE$nuk[k] + dik[, k] ^ 2) / 2) - (paramStMoE$nuk[k] + 1) / (paramStMoE$nuk[k] + dik[, k] ^ 2) + psigamma((paramStMoE$nuk[k] + 1) / 2) + ((paramStMoE$lambda[k] * dik[, k] * (dik[, k] ^ 2 - 1)) / sqrt((paramStMoE$nuk[k] + 1) * ((paramStMoE$nuk[k] + dik[, k] ^ 2) ^ 3))) * dt(mik[, k], paramStMoE$nuk[k] + 1) / pt(mik[, k], paramStMoE$nuk[k] + 1) + (1 / pt(mik[, k], paramStMoE$nuk[k] + 1)) * Integgtx[, k]
        }

        if (calcTau) {

          # Weighted skew normal linear expert likelihood
          piik_fik[, k] <- piik[, k] * (2 / sigmak) * dt(dik[, k], paramStMoE$nuk[k]) * pt(mik[, k], paramStMoE$nuk[k] + 1)

        }

      }

      if (calcTau) {

        # univStMoEpdf(paramStMoE)

        stme_pdf <<- matrix(rowSums(piik_fik)) # Skew-t mixture of experts density

        log_piik_fik <<- log(piik_fik)

        log_sum_piik_fik <<- matrix(logsumexp(log_piik_fik, 1))

        #E[Zi=k|yi]
        log_tik <- log_piik_fik - log_sum_piik_fik %*% ones(1, paramStMoE$K)
        tik <<- exp(log_tik)
      }

    }
  )
)
