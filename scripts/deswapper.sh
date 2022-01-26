#Function for getting current free memory - it can be modified to extract any other numerical data from 'free' command
currentmem () {
        local counter=0
        local input_data=$(free)
        local result
        for i in $input_data
        do
                if [[ !($i =~ [0-9]) ]]; then
                        continue;
                else
                        counter=$((counter+1))
                        if [[ $counter == '3' ]]; then
                                result=$i
                                break;
                        fi
                fi
        done
        echo $result
}

isSwapOk () { #Note for the future: Hereupon I should check if there is more total swap than two times of used (less than 50% is used xD)
        local counter=0
        local input_data=$(free)
        local result
        for i in $input_data
        do
                if [[ !($i =~ [0-9]) ]]; then
                        continue;
                else
                        counter=$((counter+1))
                        if [[ $counter == '3' ]]; then
                                result=$i
                                break;
                        fi
                fi
        done
        echo $result
}


swap () {
	swapoff -a && swapon -a
}

#Init variables
input_data=$(free)
	#echo $(free) #Test
counter=0
extractedArray=()
currentmem=currentmem

#Extract current free memory & used swap (kind of redundant, but nonetheless working...)
for i in $input_data
do
	if [[ !($i =~ [0-9]) ]]; then 
		continue
	else
		counter=$((counter+1)) 
		#echo "Extracted [$counter]: [$i]"
		extractedArray+=("$i")
	fi
done 

##Test
#echo "Arrays time!"
#for i in ${extractedArray[@]}; do
	#echo $i
#done
#echo "Based on function current free mem is: $(currentmem)"

echo "Free mem: ${extractedArray[2]}"
echo "Used Swap: ${extractedArray[counter-2]}"
freeMem=${extractedArray[2]}
usedSwap=${extractedArray[counter-2]}

#This block checks if there's enough free mem & eventually proceeds to drop cache three times.
switch=0 #Switch tells if there's enough free memory for dropping swap.
sensitivity=64000 #Parameter of minimal viable free memory margin. Currently set on 64Mib.
echo $(echo "$sensitivity+$freeMem" |bc)
if [[ $freeMem <= $usedSwap ]]; then
	echo "Not enough free memory to drop swap!"
	for i in {1..3}
	do
        echo "Dropping cache..."
	sync && echo 3 > /proc/sys/vm/drop_caches & 
	sleep 2m | if [[ $(currentmem) <= $($sensitivity+$freeMem | bc) ]]; then
			echo "It's not working! Trying again..." && continue; 
  	           else 
			switch=1
			break;
	           fi
	done
else if [[ $freeMem >= $usedSwap && $freeMem < $($sensitivity+$freeMem | bc) ]]; then
	echo "Host might not have enough swap. I'll try to drop some cache before proceeding..."
	switch=1
	sync && echo 3 > /proc/sys/vm/drop_caches &
        sleep 2m && continue;
else if [[ $freeMem > $($sensitivity+$freeMem | bc) ]]; then
	switch=1
	echo "Host seem to have a surplus of free memory. Dropping swap..."
fi

#Switch-case block in which program either diagnose 'topswappers' or just go B.A.U.
if [[ $switch == 0 ]]; then
	topswappers=$(for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n | tail -10| tac)

	echo "Not enough free memory to safely drop swap! \n
	What do?\n
	0. Possibly you can reload chef-client (Be perfectly sure if host is not in maintenance mode!)\n
	1. Create Jira ticket, comment with swapper toplist:\n
	$topswappers \n
	2. If it's a daytime, you can contact a person resposibile for the host.\n"

else
	swap & sleep 2m;
	if  


