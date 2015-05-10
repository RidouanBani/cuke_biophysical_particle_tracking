#!/bin/bash
#PBS -l walltime=1:00:00
type_year=$t
PLD=$P
bins=$b
echo "output from distances_sub.sh"
echo $t $P $bins
module load GDAL/1.9.2
module load GEOS/3.4.2
module load PROJ/4.8.0
module load R/3.1.2
module list


Rscript dispersal_distance.R $type_year $PLD $bins