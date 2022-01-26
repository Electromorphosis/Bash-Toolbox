#!/bin/bash

while getopts a: flag #a:b:c: flag ... etc.
do
	case "${flag}" in
		a) var1=${OPTARG};;
	esac
done

#Test
echo $var1
