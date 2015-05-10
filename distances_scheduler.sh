#!/bin/bash
#PBS -l walltime=12:00:00

echo "output from distances_scheduler.sh"

rm -rfv core.*
rm -rfv d_*
rm -rfv ds_*
rm -rfv dc_*
rm -rfv distances_scheduler.sh.*


module load GDAL/1.9.2
module load GEOS/3.4.2
module load PROJ/4.8.0
module load R/3.1.2
module list

echo 'Rscript distances_scheduler.R'
Rscript distances_scheduler.R