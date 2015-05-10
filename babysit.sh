x=$(ls /sb/project/uxb-461-aa/Cuke-MPA/positions/processed/ |wc -l)
x2=$(ls /sb/project/uxb-461-aa/Cuke-MPA/positions/ |wc -l)
y=$(qstat -u rdaigle |wc -l)

echo "Completed "$x" of "$x2
echo $y" jobs currently active"
echo $(qstat -u rdaigle | grep "distances_s*")