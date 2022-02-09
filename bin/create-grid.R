#!/usr/bin/Rscript

# Preamble ----------------------------------------------------------------
library(ritas)

for (f in dir(file.path(c("..", "."), "R"), "*.R", full.names = TRUE))
  source(f)

# Set up ------------------------------------------------------------------
doc <-
  'Create a regular grid from a data file

Usage:
  create-grid.R <datafile> <site> <resolution> <proj4string> [options]

Options:
  --output <output>     Output folder [default:output]

  Example: create-grid.R data/example-data.csv Basswood 10,20 "+init=epsg:26915" --output exampleRun
'

parse_args(doc)

if (interactive()) {
  datafile    <- "data/example-data.csv"
  site        <- "Site 1"
  resolution  <- "10,20"
  proj4string <- "+init=epsg:26915"
  output      <- "output"
}

# Initialize --------------------------------------------------------------
set.seed(1) # Just in case as RITAS doesn't call the RNG, at least directly

# Read data ---------------------------------------------------------------
dataDF <- read.csv(datafile)

# Munge data --------------------------------------------------------------
procDF <- dataDF[dataDF$site %in% site, ]

if (!nrow(procDF))
  stop("No data found for this site: ", site)

# Process data ------------------------------------------------------------
yVehicles <- ritas:::make_vehicle_polygons(procDF, proj4string)

for (res in unique(as.numeric(parse_csl(resolution)))) {
  yGrid     <- ritas:::make_grid(
    spdf    = yVehicles,
    width   = res,
    height  = res,
    regular = FALSE
  )

  gridPath  <- get_grid_path(output, site, res)
  if (!dir.exists(dirname(gridPath)))
    dir.create(dirname(gridPath), recursive = TRUE)

  saveRDS(yGrid, gridPath)

  sf::st_write(sf::st_as_sf(yGrid), gsub("\\.RDS", ".json", gridPath))
}
