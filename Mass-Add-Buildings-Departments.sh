#!/bin/bash
####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#	Mass-Add-Buildings-Departments.sh -- Adds all buildings or departments within a CSV file
#
# SYNOPSIS
#
#   This script will go through a CSV file, row by row, and add everything in that row into the 
#   building or department name in the JSS. Any duplicates will be ignored. Script must be run
#   on the same computer as the CSV file, and requires some user interaction. You can hardcode
#   the JSS URL, username and password, or you will be prompted for them. 
#
#   If there are any special characters in your building/department names, the script will fail. 
#   The script uses XML code to use the JSS's API to add buildings/departments into the JSS, so 
#   any special characters will fail. If you need to use special characters, replace them with their
#   XML character code, referenced here: 
#   https://www.dvteclipse.com/documentation/svlinter/How_to_use_special_characters_in_XML.3F.html#gsc.tab=0
#
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Chris Schasse on December 15th, 2016
#
####################################################################################################
#
# DEFINE VARIABLES & READ IN PARAMETERS
#
####################################################################################################


# HARDCODED VALUES ARE SET HERE

#### Hardcode values here (optional)
jssurl=''
username=''
password=''

####################################################################################################
# 
# SCRIPT CONTENTS - DO NOT MODIFY BELOW THIS LINE
#
####################################################################################################

clear

#Prompt user for the file location of the CSV
printf "Drag the CSV file here, then press Enter > "
read file

#Prompt user for JSS url (if it's not hardcoded)
if [ "$jssurl" = "" ]
then 
	printf "Enter the JSS URL";
	printf "(Example https://www.schasse.com:8443/)";
	printf "> "
	read jssurl
fi

#Prompt user for JSS Credentials
if [ "$username" = "" ]
then
	printf "Enter your JSS Username > "
	read username
fi
if [ "$password" = "" ]
then
	printf "Enter your JSS Password > "
	read -s password
fi

#Prompt users for buildings or Departments
clear
echo "Are you uploading Buildings or Departments?"
echo "(Enter B for buildings and D for Departments)"
printf "> "
read which

while [ "$which" != "b" ] && [ "$which" != "d" ] && [ "$which" != "B" ] && [ "$which" != "D" ]
do
	clear
	echo "You entered an incorrect value"
	echo "Enter B for buildings and D for Departments"
	printf "> " 
	read a
done

##########################
### RUNNING THE SCRIPT ###
##########################

#Find how many buildings there are to import on the CSV
computerqty=`awk -F, 'END {printf "%s\n", NR}' $file`

#Set a counter for the loop
counter="0"

## Buildings ##
#Checking to see if buildings were selected, then running the script with the buildings API
if [ "$which" = "b" ] || [ "$which" = "B" ]
	then
	# Loop through the CSV and submit data to the API
	while [ $counter -lt $computerqty ]
	do
		#Set the counter to +1
		counter=$((counter+1))
		#Grab the building and put it into the building variable
		building=$(sed -n ${counter}p $file)
		# Use the api to put the records into the JSS in the appropriate particularce
		curl -k -H "Content-Type: application/xml" -u ${username}:${password} ${jssurl}/JSSResource/buildings/id/0 -d "<building><name>${building//&/&#38;}</name></building>" -X POST
			# Notes about API:
			# # -k means allow invalid certificate if you dont have a trusted 3rd party cert.
			# # -H means header. -H "Content-Type: application/xml" makes it so you don't have to type out the xml header when uploading, e.g. <?xml version="1.0" 
			# # -u prompts for the user credentials, and is followed by the JSS URL
			# # -d means data to send in the requested PUT or POST, you can use this to pass values in-line without it having to read from a file.
			# # -X specifies the request type, PUT, POST, DELETE and even GET if you want to call it out.  
	done
fi

## Departments ##
#Checking to see if departments were selected, then running the script with the Departments API
if [ "$which" = "d" ] || [ "$which" = "D" ]
	then
	# Loop through the CSV and submit data to the API
	while [ $counter -lt $computerqty ]
	do
		#Set the counter to +1
		counter=$((counter+1))
		#Grab the department and put it into the department variable
		department=$(sed -n ${counter}p $file)
		# Use the api to put the records into the JSS in the appropriate place
		curl -k -H "Content-Type: application/xml" -u ${username}:${password} ${jssurl}/JSSResource/departments/id/0 -d "<department><name>${department}</name></department>" -X POST
			# Notes about API:
			# # -k means allow invalid certificate if you dont have a trusted 3rd party cert.
			# # -H means header. -H "Content-Type: application/xml" makes it so you don't have to type out the xml header when uploading, e.g. <?xml version="1.0" 
			# # -u prompts for the user credentials, and is followed by the JSS URL
			# # -d means data to send in the requested PUT or POST, you can use this to pass values in-line without it having to read from a file.
			# # -X specifies the request type, PUT, POST, DELETE and even GET if you want to call it out.  
	done
fi
