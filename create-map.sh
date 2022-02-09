#!/usr/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=64G
#SBATCH --time=2-00:00:00
#SBATCH --output=log/create-map/%J.out
#SBATCH --error=log/create-map/%J.err
#SBATCH --job-name="create-map"

script=create-map
id=${script}/$2_$3

echo "create-map.sh <datafile> <site> <year> <resolution> <nmax> <proj4string> <nCores> <output>"
echo "$0 $@"

set -x

module load gcc/7.3.0-xegsmw4
module load r/4.0.2-py3-icvulwq
module load r-rgdal/1.5-19-py3-nrxcpms
module load r-rgeos/0.5-5-py3-p45zrqd
module load r-rcpp
module load r-digest
module load r-units/0.6-7-py3-mekv67l
module load r-sf/0.9-7-py3-kpnaqc7

cd /home/ldamiano/work/ritas-deploy

Rscript bin/create-map.R "$1" "$2" "$3" "$4" "$5" "$6" --nCores "$7" --output "$8"
