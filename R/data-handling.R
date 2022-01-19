get_proj_root <- function() {
  return(".")
}

get_grid_path <- function(path, site, resolution) {
  fname <- sprintf("grid_%s.RDS", resolution)
  file.path(get_proj_root(), path, site, fname)
}
