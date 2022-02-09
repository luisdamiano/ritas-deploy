#! /bin/bash

script=create-grid
echo "create-grid.sh <datafile> <site> <resolution> <proj4string> <output>"

id=${script}/$2_$3
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=64G
#SBATCH --time=2-00:00:00
#SBATCH --output=log/${id}.out
#SBATCH --error=log/${id}.err
#SBATCH --job-name="${id}"

module load gcc/7.3.0-xegsmw4
module load r/4.0.2-py3-icvulwq

set -x
cd /home/ldamiano/work/ritas-deploy
Rscript bin/create-grid.R "$1" "$2" "$3" "$4" "$5"
