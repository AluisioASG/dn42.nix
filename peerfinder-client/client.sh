#!/usr/bin/env bash
#
# Copyright (c) 2018, sour.is
# Copyright (c) 2020, Aluísio Augusto Silva Gonçalves
# SPDX-License-Identifier: LicenseRef-Souris
#
# Measurement script for the dn42 peer finder, see http://dn42.us/peers
# Dependencies: curl, sed, ping
#
# This script is designed to be run in cron every 5 minutes, like this:
#
#   UUID=<Your UUID goes here>
#   */5 * * * * /home/foo/cron.sh
#
set -u

# This avoids synchronisation (everybody fetching jobs and running
# measurements simultaneously)
RANDOM_DELAY=30

function die() {
  echo "## PEERFINDER ERROR $(date) ## " \
    "$*"
  exit 1
}

VERSION=1.0.10
ver() { printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' '); }

echo "STARTING PEERFINDER (v. $VERSION)"

SLEEP=$((RANDOM % RANDOM_DELAY))

# check for ping binary
PING=$(which ping)
if [ -z "$PING" ]; then
  die "Unable to find a suitable ping binary."
fi

CURL=$(which curl)
if [ -z "$CURL" ]; then
  die "Unable to find a suitable curl binary."
fi
CURL="$CURL -A PeerFinder -sf"

case $OSTYPE in
  solaris*)
    GREP=$(which ggrep)

    function ping_cmd() {
      $PING -sn $3 56 $2
    }
    ;;
  *-gnu|*)
    # check for IPv6 binary. if ping6 is missing assume 'ping -6'
    PING6=$(which ping6)
    [ -z "$PING6" -a -n "$PING" ] && PING6="$PING -6"

    GREP=$(which grep)

    function ping_cmd() {
      [ "$1" -eq "1" -a -n "$PING" ] && $PING -nqc $2 $3
      [ "$1" -eq "2" -a -n "$PING6" ] && $PING6 -nqc $2 $3
    }
    ;;
esac

while true ; do

  JOB=$(mktemp)

  $CURL -H 'accept: text/environment' "$PEERFINDER/pending/$UUID" | tee $JOB

  REQ_ID=$($GREP REQ_ID $JOB|cut -d'=' -f2|tr -d '[$`;><{}%|&!()]"/\\')
  REQ_IP=$($GREP REQ_IP $JOB|cut -d'=' -f2|tr -d '[$`;><{}%|&!()]"/\\')
  REQ_FAMILY=$($GREP REQ_FAMILY $JOB|cut -d'=' -f2|tr -d '[$`;><{}%|&!()]"/\\')
  CUR_VERSION=$($GREP SCRIPT_VERSION $JOB|cut -d'=' -f2|tr -d '[$`;><{}%|&!()]"/\\')

  rm "$JOB"

  if [ $(ver "$VERSION") -lt $(ver "$CUR_VERSION") ]; then
    echo "## PEERFINDER WARN $(date) ## " \
         "Current script version is $CUR_VERSION. You are running $VERSION " \
         "Get it here: https://dn42.us/peers/script"
  fi

  # Avoid empty fields
  [ -z "$REQ_ID" -a -z "$REQ_IP" ] && exit

  echo "PINGING TO: $REQ_IP for $REQ_ID..."

  # Parsing ping output, for Linux
  if ! output=$(ping_cmd "$REQ_FAMILY" "$NB_PINGS" "$REQ_IP" 2>&1 | $GREP -A1 "packets transmitted"); then
    sent=0
    received=0
    args="res_latency=NULL"
    echo "Target $REQ_ID ($REQ_IP) is unreachable"
  else
     pattern='([0-9]*) packets transmitted, ([0-9]*)( packets)? received'
     if [[ $output =~ $pattern ]]; then
         sent=${BASH_REMATCH[1]}
         received=${BASH_REMATCH[2]}
         if [ "$received" -eq 0 ]
         then
             args="res_latency=NULL"
             echo "Target $REQ_ID ($REQ_IP) is unreachable"
         else
             pattern='(rtt|round-trip).* min/avg/max.*= ([^/]*)/([^/]*)/([^/]*)(/(.*))?( ms)?'
             if [[ $output =~ $pattern ]]; then
                 minrtt=${BASH_REMATCH[1]}
                 avgrtt=${BASH_REMATCH[2]}
                 maxrtt=${BASH_REMATCH[3]}
                 jitter=${BASH_REMATCH[4]}
                 [ -z "$avgrtt" ] && exit
                 echo "RTT to target $REQ_ID ($REQ_IP) is $avgrtt"
                 args="res_latency=${avgrtt}"
             else
                 args="res_latency=NULL"
             fi
         fi
      else
          args="res_latency=NULL"
      fi
  fi

  # Report results back to peerfinder
  $CURL -X POST "$PEERFINDER/req/$REQ_ID" -d "peer_id=$UUID&peer_version=$VERSION&$args" -H 'accept: text/environment'

done
