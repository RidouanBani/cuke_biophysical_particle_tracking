#!/bin/bash

while  read -r t P 
do
	i=$t$P
	qsub -A uxb-461-aa -N d_$i -v t=$t,P=$P ./distances.sh
done < "todo"