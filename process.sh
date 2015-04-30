rm -rfv process.sh.*
rm -rfv distances.sh.*

while  read -r t P 
do
	qsub -A uxb-461-aa -v t=$t,P=$P ./distances.sh
done < "todo"