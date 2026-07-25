# functions

tighten_panels <- function(gp, gap=0.02) {
  lay <- gp$x$layout
  xax <- grep("^xaxis", names(lay), value=TRUE)
  old <- setNames(lapply(xax, function(a) lay[[a]]$domain), xax)
  doms <- t(sapply(old, identity))
  cols <- sort(unique(round(doms[, 1], 6)))
  n <- length(cols); left <- min(doms[, 1]); right <- max(doms[, 2])
  w <- (right - left - gap * (n - 1)) / n

  new <- list()
  for (a in xax) {
    k  <- match(round(old[[a]][1], 6), cols)
    x0 <- left + (k - 1) * (w + gap)
    new[[a]] <- c(x0, x0 + w)
    gp$x$layout[[a]]$domain <- new[[a]]
  }
  remap <- function(x) {                       # old paper coord -> new
    for (a in xax) {
      o <- old[[a]]; nw <- new[[a]]
      if (x >= o[1] - 1e-9 && x <= o[2] + 1e-9) {
        f <- if (diff(o) > 0) (x - o[1]) / diff(o) else 0
        return(nw[1] + f * diff(nw))
      }
    }
    x
  }
  if (!is.null(gp$x$layout$shapes))
    gp$x$layout$shapes <- lapply(gp$x$layout$shapes, function(s) {
      if (identical(s$xref, "paper") && !is.null(s$x0)) {
        s$x0 <- remap(s$x0); s$x1 <- remap(s$x1)
      }; s })
  if (!is.null(gp$x$layout$annotations))
    gp$x$layout$annotations <- lapply(gp$x$layout$annotations, function(a2) {
      if (identical(a2$xref, "paper") && !is.null(a2$x)) a2$x <- remap(a2$x)
      a2 })
  gp
}

