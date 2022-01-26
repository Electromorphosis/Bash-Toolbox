#!/bin/bash

while getopts a: flag #Now it's 'a' like 'array'.
do
	case "${flag}" in
		a) arr1=${OPTARG};;
	esac
done

arr1="( $arr1 )"

#Test
echo $arr1
