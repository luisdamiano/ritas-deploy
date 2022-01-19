parse_args <- function(doc, typeConvert = TRUE, stripNames = TRUE,
                       attachVars = TRUE) {
  if (interactive()) {
    warning("Command line arguments not parsed (interactive mode)")
    return()
  }

  l <- docopt::docopt(doc, strict = TRUE)

  if (typeConvert)
    l <- lapply(l, type.convert, as.is = TRUE)

  if (stripNames)
    names(l) <- gsub("[<>-]", "", names(l))

  if (attachVars)
    for (v in names(l))
      assign(v, l[[v]], .GlobalEnv)

  return(invisible(l))
}

parse_csl  <- function(x) {
  strsplit(x, ",")[[1]]
}
