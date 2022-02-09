#!/usr/bin/Rscript

# Preamble ----------------------------------------------------------------
library(ritas)

for (f in dir(file.path(c("..", "."), "R"), "*.R", full.names = TRUE))
  source(f)

# Set up ------------------------------------------------------------------
doc <-
  'Create a RITAS map from a data file

Usage:
  create-map.R <datafile> <site> <year> <resolution> <nmax> <proj4string> [options]

Options:
  --nCores <nCores>     Number of cores [default: 1]
  --output <output>     Output folder [default:output]

  Example: create-map.R data/example-data.csv Basswood 2007 10,20 30 "+init=epsg:26915" --nCores 16 --output exampleRun
'

parse_args(doc)

if (interactive()) {
  datafile    <- "data/example-data.csv"
  site        <- "Basswood"
  year        <- "2007"
  resolution  <- "10,20"
  nmax        <- 30
  proj4string <- "+init=epsg:26915"
  nCores      <- 12
  output      <- "output"
}

# Initialize --------------------------------------------------------------
set.seed(1) # Just in case as RITAS doesn't call the RNG, at least directly

# Read data ---------------------------------------------------------------
dataDF <- read.csv(datafile)

# Munge data --------------------------------------------------------------
procDF <- dataDF[dataDF$site %in% site & dataDF$year %in% year, ]

if (!nrow(procDF))
  stop("No data found for this site and year: ", site, " ", year)

# Process data ------------------------------------------------------------
for (res in unique(as.numeric(parse_csl(resolution)))) {
  gridPath <- get_grid_path(output, site, res)
  gridObj  <- if (file.exists(gridPath)) { readRDS(gridPath) }

  ritas(
    df          = procDF,
    proj4string = proj4string,
    site        = site,
    year        = year,
    resolution  = res,
    nmax        = nmax,
    predictAt   = gridObj,
    folder      = file.path(get_proj_root(), output),
    nCores      = nCores
  )
}

# Export to geoJSON format ------------------------------------------------
write_geoJSON <- function(x, filename) {
  sf::write_sf(sf::st_as_sf(x), sprintf("%s.geojson", filename))
}

expDir <- file.path(get_proj_root(), output, site, year, "obj")
expRE  <- "(00(1|2|5|6)).*?\\.RDS"
files  <- dir(expDir, expRE, full.names = TRUE, recursive = TRUE)

for (f in files) {
  write_geoJSON(readRDS(f), tools::file_path_sans_ext(f))
}
