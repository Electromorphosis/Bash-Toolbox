#!/bin/bash

while getopts h: flag #Now it's 'h' like 'hosts'.
do
	case "${flag}" in
		h) arr1=${OPTARG};;
	esac
done

#Test
for i in ${arr1[@]};
do
	ssh $i ls &
done

