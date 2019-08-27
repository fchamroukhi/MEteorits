#' A Reference Class which represents a fitted StMoE model.
#'
#' ModelStMoE represents an estimated StMoE model.
#'
#' @field param A [ParamStMoE][ParamStMoE] object. It contains the estimated
#'   values of the parameters.
#' @field stat A [StatStMoE][StatStMoE] object. It contains all the statistics
#'   associated to the StMoE model.
#' @seealso [ParamStMoE], [StatStMoE]
#' @export
ModelStMoE <- setRefClass(
  "ModelStMoE",
  fields = list(
    param = "ParamStMoE",
    stat = "StatStMoE"
  ),
  methods = list(
    plot = function(what = c("meancurve", "confregions", "clusters", "loglikelihood"), ...) {
      "Plot method.
      \\describe{
        \\item{\\code{what}}{The type of graph requested:
          \\itemize{
            \\item \\code{\"meancurve\" = } Estimated mean and estimated
              experts means given the input \\code{X} (fields \\code{Ey} and
              \\code{Ey_k} of class \\link{StatStMoE}).
            \\item \\code{\"confregions\" = } Estimated mean and confidence
              regions. Confidence regions are computed as plus and minus twice
              the estimated standard deviation (the squarre root of the field
              \\code{Vary} of class \\link{StatStMoE}).
            \\item \\code{\"clusters\" = } Estimated experts means (field
              \\code{Ey_k}) and hard partition (field \\code{klas} of class
              \\link{StatStMoE}).
            \\item \\code{\"loglikelihood\" = } Value of the log-likelihood for
              each iteration (field \\code{stored_loglik} of class
              \\link{StatStMoE}).
          }
        }
        \\item{\\code{\\dots}}{Other graphics parameters.}
      }
      By default, all the graphs mentioned above are produced."

      what <- match.arg(what, several.ok = TRUE)

      oldpar <- par(no.readonly = TRUE)
      on.exit(par(oldpar), add = TRUE)

      colorsvec = rainbow(param$K)

      if (any(what == "meancurve")) {
        par(mfrow = c(2, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$X, param$Y, ylab = "y", xlab = "x", cex = 0.7, pch = 3, ...)
        title(main = "Estimated mean and experts")
        for (k in 1:param$K) {
          lines(param$X, stat$Ey_k[, k], col = "red", lty = "dotted", lwd = 1.5, ...)
        }
        lines(param$X, stat$Ey, col = "red", lwd = 1.5, ...)

        plot.default(param$X, stat$piik[, 1], type = "l", xlab = "x", ylab = "Mixing probabilities", col = colorsvec[1], ...)
        title(main = "Mixing probabilities")
        for (k in 2:param$K) {
          lines(param$X, stat$piik[, k], col = colorsvec[k], ...)
        }
      }

      if (any(what == "confregions")) {
        # Data, Estimated mean functions and 2*sigma confidence regions
        par(mfrow = c(1, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$X, param$Y, ylab = "y", xlab = "x", cex = 0.7, pch = 3, ...)
        title(main = "Estimated mean and confidence regions")
        lines(param$X, stat$Ey, col = "red", lwd = 1.5)
        lines(param$X, stat$Ey - 2 * sqrt(stat$Vary), col = "red", lty = "dotted", lwd = 1.5, ...)
        lines(param$X, stat$Ey + 2 * sqrt(stat$Vary), col = "red", lty = "dotted", lwd = 1.5, ...)
      }

      if (any(what == "clusters")) {
        # Obtained partition
        par(mfrow = c(1, 1), mai = c(0.6, 1, 0.5, 0.5), mgp = c(2, 1, 0))
        plot.default(param$X, param$Y, ylab = "y", xlab = "x", cex = 0.7, pch = 3, ...)
        title(main = "Estimated experts and clusters")
        for (k in 1:param$K) {
          lines(param$X, stat$Ey_k[, k], col = colorsvec[k], lty = "dotted", lwd = 1.5, ...)
        }
        for (k in 1:param$K) {
          index <- stat$klas == k
          points(param$X[index], param$Y[index], col = colorsvec[k], cex = 0.7, pch = 3, ...)
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
