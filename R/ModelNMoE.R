#' A Reference Class which represents a fitted NMoE model.
#'
#' ModelNMoE represents a [NMoE][ModelNMoE] model for which parameters have
#' been estimated.
#'
#' @usage NULL
#' @field param A [ParamNMoE][ParamNMoE] object. It contains the estimated values of the parameters.
#' @field stat A [StatNMoE][StatNMoE] object. It contains all the statistics associated to the NMoE model.
#' @seealso [ParamNMoE], [StatNMoE]
#' @export
ModelNMoE <- setRefClass(
  "ModelNMoE",
  fields = list(
    param = "ParamNMoE",
    stat = "StatNMoE"
  ),
  methods = list(
    plot = function(what = c("meancurve", "confregions", "clusters", "loglikelihood"), ...) {

      what <- match.arg(what, several.ok = TRUE)

      oldpar <- par(no.readonly = TRUE)
      on.exit(par(oldpar), add = TRUE)

      colorsvec = rainbow(param$K)

      if (any(what == "meancurve")) {
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$fData$X, param$fData$Y, ylab = "y", xlab = "x", cex = 0.7, pch = 3, ...)
        title(main = "Estimated mean and experts")
        for (k in 1:param$K) {
          lines(param$fData$X, stat$Ey_k[, k], col = "red", lty = "dotted", lwd = 1.5, ...)
        }
        lines(param$fData$X, stat$Ey, col = "red", lwd = 1.5, ...)

        plot.default(param$fData$X, stat$piik[, 1], type = "l", xlab = "x", ylab = "Mixing probabilities", col = colorsvec[1], ...)
        title(main = "Mixing probabilities")
        for (k in 2:param$K) {
          lines(param$fData$X, stat$piik[, k], col = colorsvec[k], ...)
        }
      }

      if (any(what == "confregions")) {
        # Data, Estimated mean functions and 2*sigma confidence regions
        par(mfrow = c(1, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$fData$X, param$fData$Y, ylab = "y", xlab = "x", cex = 0.7, pch = 3, ...)
        title(main = "Estimated mean and confidence regions")
        lines(param$fData$X, stat$Ey, col = "red", lwd = 1.5)
        lines(param$fData$X, stat$Ey - 2 * sqrt(stat$Vary), col = "red", lty = "dotted", lwd = 1.5, ...)
        lines(param$fData$X, stat$Ey + 2 * sqrt(stat$Vary), col = "red", lty = "dotted", lwd = 1.5, ...)
      }

      if (any(what == "clusters")) {
        # Obtained partition
        par(mfrow = c(1, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$fData$X, param$fData$Y, ylab = "y", xlab = "x", cex = 0.7, pch = 3, ...)
        title(main = "Estimated experts and clusters")
        for (k in 1:param$K) {
          lines(param$fData$X, stat$Ey_k[, k], col = colorsvec[k], lty = "dotted", lwd = 1.5, ...)
        }
        for (k in 1:param$K) {
          index <- stat$klas == k
          points(param$fData$X[index], param$fData$Y[index, ], col = colorsvec[k], cex = 0.7, pch = 3, ...)
        }
      }

      if (any(what == "loglikelihood")) {
        # Observed data log-likelihood
        par(mfrow = c(1, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(1:length(stat$stored_loglik), stat$stored_loglik, type = "l", col = "blue", xlab = "EM iteration number", ylab = "Observed data log-likelihood", ...)
        title(main = "Log-Likelihood")
      }

    }
  )
)
