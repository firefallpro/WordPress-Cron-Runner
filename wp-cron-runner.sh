#!/bin/bash
# Managed on GitHub: https://github.com/firefallpro/WordPress-Cron-Runner
#
# wp-cron-runner.sh
# This shell script handles cron jobs that run wp-cron.php for various WordPress installs that share the same server, by adding a random (up to 60 second) delay to reduce possible performance costs that would be incurred by running scripts concurrently. The script also appends a timestamp to prevent caching if any caching service is used i.e. via CloudFlare or NGINX.
# i.e. /usr/local/bin/wp-cron-runner.sh http://www.example.com/wp-cron.php
#
# @version 0.1.0, 2017-3-17
# @author Scott Park <scott@firefallpro.com>, Aric Ng <aric@firefallpro.com>
# @link http://www.firefallpro.com/
# @license http://www.firefallpro.com/license.txt
# @copyright Copyright (c) 2016 Firefall, LLC
#
# 0.1.0 2017-3-17
# Added --ipv4 flag added to curl request
# Added -h option to trigger --resolve on curl request, must be formatted in host:port:address
 
verbose="-s -S"
resolve=""
offset=0
url=$1

printf "\n"

# Look for v in options; stop script if other options are found
while getopts ":vh:" opt; do 
	case $opt in
		v) 
			# v found, shift options
			printf "wp-cron-runner: Verbose mode\n"
			verbose="-v" 
			offset=$(($offset + 1))
			;;
		h)
			# h found, set --resolve and its argument for curl
			resolve="--resolve $OPTARG"
			printf "wp-cron-runner: Set to force resolve of host: $resolve\n"
			offset=$((offset + 2))
			;;
		*) 
			printf "\nwp-cron-runner: Unexpected flag found: -$OPTARG: Script Terminated\n\n"
			exit 1
			;;
	esac
done

printf "\n"

# Look for absolute url after offset
for ((c = 0; c < offset; c++))
do
	shift $(($OPTIND-1))
done

url=$1

# Check if URL is empty
if [ -z "$url" ]; then
	printf "\nwp-cron-runner.sh: Expecting URL: Empty argument supplied: Script Terminated\n\n" 
	exit 1
fi

if [[ $verbose == "-v" ]]; then
	printf "\nwp-cron-runner.sh: Attempting to run cURL command on $url"
	
	if [ -n "$resolve" ]; then
		printf " with host $resolve"
	fi
fi

# This runs wp-cron.php with up to 60 seconds of entropy to prevent overlap with other sites
delay=$(($RANDOM%60));

if [ "$verbose" == "-v" ]; then
	printf "\nwp-cron-runner.sh: Sleeping for $delay secs \n\n"
fi

/bin/sleep $delay;
/usr/bin/curl --ipv4 $verbose $resolve $url?`date +\%s`;
