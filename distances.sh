#!/bin/bash
#PBS -l nodes=1:ppn=4,pmem=31700m,walltime=10:00:00:00
type_year=$t
PLD=$P
module load GDAL/1.9.2
module load GEOS/3.4.2
module load PROJ/4.8.0
module load R/3.1.2
module list

rm -rfv /sb/project/uxb-461-aa/Cuke-MPA/runs/type_year
rm -rfv /sb/project/uxb-461-aa/Cuke-MPA/output/type_year

#qsub -A uxb-461-aa -v t=G1998,P=120 ./distances.sh

Rscript dispersal_distance.R $type_year $PLD