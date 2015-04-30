century=$1
decade=$2
year=$3

cd cuke-MPA/Future/release_locations/
numfiles=(*)
numfiles=${#numfiles[@]}
cd
rm -rfv go.sh.*
rm -rfv run.sh.*
rm -rfv run_sub.sh.*
rm -rfv /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year
rm -rfv /sb/project/uxb-461-aa/Cuke-MPA/output/S$year

for t in 1 15 29 43 57 71 85 99 113 127 141 225 239
#for t in {152..153}
do
	#for i in {80..82}
	for i in `eval echo {1..$numfiles}`
	do
		mkdir -p /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]
		mkdir -p /sb/project/uxb-461-aa/Cuke-MPA/output/S$year/$[t]/$[i]

		cp cuke-MPA/Future/* /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/

		rm -rfv /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/release_locations.txt
		cp cuke-MPA/Future/release_locations/rl_$i.txt /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/release_locations.txt
		cp run_sub.sh /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/run_sub.sh

		sed -i -e "s/timetobereplaced/$t/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/run_sub.sh
		sed -i -e "s/celltobereplaced/$i/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/run_sub.sh
		sed -i -e "s/grid/S$year/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/run_sub.sh
		
		mv /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/run_sub.sh /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/run_sub_S$year.sh

		sed -i -e "s/filenum = 152/filenum = $t/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/LTRANS.data
		sed -i -e "s/outputtobereplaced/S$year/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/LTRANS.data
		sed -i -e "s/timetobereplaced/$t/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/LTRANS.data
		sed -i -e "s/celltobereplaced/$i/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/LTRANS.data
		nparts=$(cat /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/release_locations.txt | wc -l)
		sed -i -e "s/99999999/$nparts/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/LTRANS.data
		sed -i -e "s/yeartobereplaced/$year/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/LTRANS.data
		sed -i -e "s/decadetobereplaced/$decade/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/LTRANS.data	
		if [ $decade -ne 98 ]
		then
			sed -i -e "s/_gb_his_/_his_/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i]/LTRANS.data
		fi
		
		cd /sb/project/uxb-461-aa/Cuke-MPA/runs/S$year/$[t]/$[i] 
		qsub -A uxb-461-aa run_sub_S$year.sh
		cd
	done
done 