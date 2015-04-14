#!/bin/bash
#PBS -l walltime=47:55:55 
#PBS -m e -M daigleremi@gmail.com
cd cuke-MPA/Future/release_locations/
numfiles=(*)
numfiles=${#numfiles[@]}
cd
rm -rfv go.sh.*
rm -rfv run.sh.*
rm -rfv run_sub.sh.*
rm -rfv runs/grid*
rm -rfv output/grid*

for t in {152..212}
#for t in {152..153}
do
	#for i in {80..82}
	for i in `eval echo {1..$numfiles}`
	do
		mkdir -p runs/grid/$[t]/$[i]
		mkdir -p output/grid/$[t]/$[i]

		cp cuke-MPA/Future/* runs/grid/$[t]/$[i]/

		rm -rfv runs/grid/$[t]/$[i]/release_locations.txt
		cp cuke-MPA/Future/release_locations/rl_$i.txt runs/grid/$[t]/$[i]/release_locations.txt
		cp run_sub.sh runs/grid/$[t]/$[i]/run_sub.sh

		sed -i -e "s/timetobereplaced/$t/g" runs/grid/$[t]/$[i]/run_sub.sh
		sed -i -e "s/celltobereplaced/$i/g" runs/grid/$[t]/$[i]/run_sub.sh
		sed -i -e "s/filenum = 152/filenum = $t/g" runs/grid/$[t]/$[i]/LTRANS.data
		sed -i -e "s/outputtobereplaced/grid/g" runs/grid/$[t]/$[i]/LTRANS.data
		sed -i -e "s/timetobereplaced/$t/g" runs/grid/$[t]/$[i]/LTRANS.data
		sed -i -e "s/celltobereplaced/$i/g" runs/grid/$[t]/$[i]/LTRANS.data
		nparts=$(cat runs/grid/$[t]/$[i]/release_locations.txt | wc -l)
		sed -i -e "s/99999999/$nparts/g" runs/grid/$[t]/$[i]/LTRANS.data
		qsub -A uxb-461-aa run_sub.sh

	done
done 