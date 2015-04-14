century=$1
decade=$2
year=$3
rm -rfv ~/cuke-MPA/Future/output/*
rm -rfv ~/run.sh.*
rm -rfv ~/run_amanda.sh.*
rm -rfv ~/run_sub.sh.*
rm -rfv /sb/project/uxb-461-aa/Cuke-MPA/output/A$year
rm -rfv /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year

i=1
for t in {152..212}
#for t in {152..153}
do
	mkdir -p /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]
   	cp ~/cuke-MPA/Future/* /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/

	mkdir -p /sb/project/uxb-461-aa/Cuke-MPA/output/A$year/$[t]/$[i]
	
	cp run_amanda.sh /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/run_amanda.sh
	sed -i -e "s/celltobereplaced/$i/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/run_amanda.sh
	sed -i -e "s/timetobereplaced/$t/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/run_amanda.sh
	sed -i -e "s/Amanda/A$year/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/run_amanda.sh
	
	mv /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/run_amanda.sh /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/run_amanda_$year.sh


	sed -i -e "s/filenum = 152/filenum = $t/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/LTRANS.data
	sed -i -e "s/outputtobereplaced/A$year/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/LTRANS.data
	sed -i -e "s/celltobereplaced/$i/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/LTRANS.data
	sed -i -e "s/timetobereplaced/$t/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/LTRANS.data
	nparts=$(cat /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/release_locations.txt | wc -l)
	sed -i -e "s/99999999/$nparts/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/LTRANS.data
	sed -i -e "s/yeartobereplaced/$year/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/LTRANS.data
	sed -i -e "s/decadetobereplaced/$decade/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/LTRANS.data
	if [ $decade -ne 98 ]
		then
			sed -i -e "s/_gb_his_/_his_/g" /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]/LTRANS.data
	fi
	cd /sb/project/uxb-461-aa/Cuke-MPA/runs/A$year/$[t]/$[i]
	qsub -A uxb-461-aa run_amanda_$year.sh
	cd
done