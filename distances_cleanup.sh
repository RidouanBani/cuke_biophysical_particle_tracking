#!/bin/bash
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=2

type_year=$t
PLD=$P
echo "output from distances_cleanup.sh"
echo $t $P 

rm -rfv core.*
rm -rfv d_*
rm -rfv ds_*
 rm -rfv dc_$type_year*

module load GDAL/1.9.2
module load GEOS/3.4.2
module load PROJ/4.8.0
module load R/3.1.2
module list

echo 'Rscript distances_cleanup.R' $type_year $PLD
Rscript distances_cleanup.R $type_year $PLD
