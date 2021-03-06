#!/bin/bash
#PBS -l walltime=3:00:00
#PBS -l nodes=1:ppn=2
type_year=$t
PLD=$P

rm -rfv core.*
rm -rfv d_*
rm -rfv ds_*
rm -rfv dc_*

module load GDAL/1.9.2
module load GEOS/3.4.2
module load PROJ/4.8.0
module load R/3.1.2
module list

Rscript distances_master.R $type_year $PLD