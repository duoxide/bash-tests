#!/bin/bash

echo -e "This is the content of input.csv file\n"
cat input.csv
if [ -f output.csv ]
then
	rm output.csv
	ls -a
else
	echo -e "No output.csv file yet in the folder\n"
	ls -a
fi
echo "Parsing a file..."
exec < input.csv
read header
header="$header,IP reachable,Hostname Registered,SSH Enabled"
echo $header >> output.csv
while read line
do
	line1=$(cut -d ',' -f 1 <<< "$line")
	line2=$(cut -d ',' -f 2 <<< "$line")

	# check if PINGable

	ping $line1 -c2 1>/dev/null 2>/dev/null
	success=$?
	if [ $success -eq 0 ]
	then
		result="$line,YES"
	else
		result="$line,NO"
	fi

	# check if dig returns an IP for hostname

	success2=$(dig $line2 +short)
	if [ -z $success2 ]
        then
                result="$result,NO"
        else
                result="$result,YES"
        fi

	#check if ssh port 22 is open and accepts connections

	sshstatus=$(nmap $line1 -Pn -p 22 | egrep -io 'open|closed|filtered')
	if [ $sshstatus == "open" ];then
   		echo "$result,YES" >> output.csv
	elif [ $sshstatus == "filtered" ]; then
		echo "$result,NO" >> output.csv
	else
		echo "$result,NO" >> output.csv
	fi
done
echo "New file created with new contents"
ls -a
cat output.csv
