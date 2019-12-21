#!/bin/bash
#
# v0.1.10  dec/2019  by castaway

HELP="SINOPSIS
	bakkt.sh [-hV]


	Bakkt price ticker and contract volume from <https://www.bakkt.com/> 
	at the terminal. The default option is to get intraday/last weekday 
	prices and volume.

	Market data delayed minimum of 15 minutes. 

	Required software: Bash, JQ and cURL or Wget.


WARRANTY
	Licensed under the GNU Public License v3 or better.
 	
	This programme is distributed without support or bug corrections.

	Give me a nickle! =)

		bc1qlxm5dfjl58whg6tvtszg5pfna9mn2cr2nulnjr


OPTIONS
	-j 	Debug; print JSON.

	-h 	Show this help.

	-V 	Print this script version."

# Parse options
while getopts ":jhV" opt; do
	case ${opt} in
		j ) # Print JSON
			PJSON=1
			;;
		h ) # Help
	      		echo -e "${HELP}"
	      		exit 0
	      		;;
		V ) # Version of Script
	      		head "${0}" | grep -e '# v'
	      		exit 0
	      		;;
		\? )
	     		echo "Invalid Option: -$OPTARG" 1>&2
	     		exit 1
	     		;;
  	esac
done
shift $((OPTIND -1))

#Check for JQ
if ! command -v jq &>/dev/null; then
	printf "JQ is required.\n" 1>&2
	exit 1
fi

# Test if cURL or Wget is available
if command -v curl &>/dev/null; then
	YOURAPP="curl -s"
elif command -v wget &>/dev/null; then
	YOURAPP="wget -qO-"
else
	printf "Package cURL or Wget is needed.\n" 1>&2
	exit 1
fi

#Some defaults
CONTRACTURL="https://www.bakkt.com/api/bakkt/marketdata/contractslist/product/23808/hub/26066"

# Contracts opt -- Default option
DATA0="$(${YOURAPP} "${CONTRACTURL}")"

# Print JSON?
if [[ -n ${PJSON} ]]; then
	printf "%s\n" "${DATA0}"
	exit
fi

printf "Bakkt Contract List\n"
jq -r 'reverse[]|"",
	"Market_ID: \(.marketId // empty)",
	"Strip____: \(.marketStrip // empty)",
	"Last_time: \(.lastTime // empty)",
	"End_date_: \(.endDate // empty)",
	"LastPrice: \(.lastPrice // empty)",
	"Change(%): \(.change // empty)",
	"Volume___: \(.volume // empty)"' <<< "${DATA0}"

exit

# Dead code

