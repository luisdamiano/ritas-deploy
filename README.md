# RITAS deployment repo

This repo deploys a basic file and folder structure to create smooth
maps using the
(https://dr.lib.iastate.edu/handle/20.500.12876/93760)[RITAS
algorithm].

## What do I need?

- R > 3.5.0 and the `ritas` R package
- a data file with the format described below
- a [PROJ](https://en.wikipedia.org/wiki/PROJ) string with the cartographic projections

### R package

Run the following line from R after figuring out your credentials.

```R
devtools::install_github("luisdamiano/ritas-pkg")
```

A possibly easier alternative is to clone the repo in a temporary folder
and install locally

```bash
git clone git@github.com:luisdamiano/ritas-pkg.git && \
    Rscript -e "devtools::install_local(\"ritas-pkg\")"
```

### Data file

A csv file in wide format with one yield monitor observation per row
and at least the following column variables (include header in the
first row). Unmatched columns will not be used.

- `site`: site name, e.g., Basswood, Orbweaver North
- `year`: year, e.g., 2020
- `record`: a numeric, ordered index
- `x`: latitude in meters
- `y`: longitude in meters
- `mass`: the variable to smooth, e.g., harvested mass in kilograms at standard market moisture
- `swath`: swath width in meters
- `d`: distance in meters between the current row observation and the previous row observation, 

Here are a few illustrative rows with two sites with two and one year
of data. See `data/example-data.csv` for a full data file.

```
""  ,"site","year","record","x","y","mass","swath","d"
"1" ,"Site 1","2007",0,476885.588878994,4598424.10719146,2.63945578231293,7.61962816214569,NA
"2" ,"Site 1","2007",1,476888.675953105,4598424.31933417,5.07482993197279,7.61962816214569,2.51447729350808
"3" ,"Site 1","2007",2,476891.846798156,4598424.64223081,6.82993197278912,7.61962816214569,3.14944630702022
"4" ,"Site 1","2008",0,476895.184117385,4598424.85357399,8.10884353741497,7.61962816214569,NA
"5" ,"Site 1","2008",1,476898.52108056,4598424.95389868,9.64625850340136,7.61962816214569,3.22564258864167
"6" ,"Site C","2007",0,476902.025229783,4598425.1647103,11.1020408163265,7.61962816214569,NA
"7" ,"Site C","2017",1,476905.528667318,4598425.15348355,11.3741496598639,7.61962816214569,3.30183887026313
"8" ,"Site C","2017",2,476908.86598586,4598425.36483307,10.8707482993197,7.61962816214569,3.32723763080362
"9" ,"Site C","2017",3,476912.286363738,4598425.46489689,10.1768707482993,7.61962816214569,3.27644010972265
```

## How do I run it?

Optionally, for a given site you can create a grid with squares of
arbitrary side length in meters. If a grid exists, all the smoothed
yield maps generated for a site will be predicted at the grid
location. This is desirable if you want to visualize or analyze the
same locations across years. 

To create a map, you need to specify a data file, a site name, a grid
resolution and a PROJ string. Optionally, you can specify a folder
name for the output files. Call `./bin/create-grid.R` with no
arguments to read the help. Note that you can produce more than one
grid with different resolutions by passing comma-separated values,
e.g., `10,20` to produce two grids with 10x10 and 20x20 meter
tiles. The grid file will be written in
`{output}/{site}/grid_{resolution}.RDS`.

```bash
./bin/create-grid.R \
    data/example-data.csv \
    "Site 1" \
    10,20 \
    "+init=epsg:26915" \
    --output exampleRun
```

To produce a map, you need to specify a data file, a site name, a
year, a map resolution, a number of nearest neighbour to use for
interpolation at the smoothing step and a PROJ string. Optionally, you
can specify the number of cores used for the interpolation (and only
for interpolation) and an folder name for the output files. Call
`./bin/create-map.R` with no arguments to read the help. The map and
extensive log files will be written in
`{output}/{site}/{year}/obj/{site}_{year}_005_smoothed.RDS` and
`{output}/{site}/{year}/log_{timestamp}.txt` respectively. Side effect
files, which need be deleted manually, are created in the `.cache/` on
the project root folder.

```bash
./bin/create-map.R \
    data/example-data.csv \
    "Site 1" \
    2007 \
    10,20 \
    30 \
    "+init=epsg:26915" \
    --nCores 16 \
    --output exampleRun
```

### Tips

- create the grid once per site, but rebuild if adding new years
- watch the `.cache` folder in the project root, which can get large
- use different output folder names when trying different things on
the same data set
- use the regex `^.*?005.*?\.RDS` to match all smoothed map files
- use simplified site names, e.g., `libcon` instead of `Law Library of Congress`

## Doesn't work?

### DOs

- read the logs
- have a header in the data files
- express data coordinates in meters, e.g., projected in UTM
- run your commands from the root folder and not from, say, bin or data
- escape blank spaces in site names and relevant characters in the PROJ
  string if calling the scripts from cli
- be case sensitive
- leave no blank spaces around commas if specifying more than one resolution

### If headache persists

Submit a PR, open an issue, or send me an email if too lazy.
