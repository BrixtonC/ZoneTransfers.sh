#!/bin/bash
#
# Name: ZoneTransfers.sh
# Description: Try zone transfers at the domain target
# Author: Brixton Cat
# Date: 19 Mar 2012
# Version: 0.2
# Sintax: ./ZoneTransfer.sh <domain>
#

### FUNCTIONS
function Filter {
# Filtering files
#

  echo "[*] Filtering results"
  # Obtain first col of dig results = domains
  awk '{print $1}' tmp | sed 's/\.$//g' | sort -u > domains.tmp
  # Obtain last col of dig results = IPs + domains
  awk '{print $NF}' tmp | sort -u > results.tmp
  # Save domains of last col in domains.tmp file
  grep -E "\.$" results.tmp | sed 's/\.$//g' >> domains.tmp
  # Sort IPs and save results in ipaddress.lst file
  grep -oE "[0-9]{1,3}(\.[0-9]{1,3}){3}" results.tmp | sort -u > ipaddress.lst
  # Sort domains
  sort -u domains.tmp >> domains.lst

}

function NameServers {
# This function obtain Name Servers of the target domain and save this
# in NAMESERVERS variable
#

  echo "[*] Obtain Name Servers"
  local NAMESERVERS=`dig NS $DOMAIN | grep -E "IN" | \
    grep -oE "[0-9a-z\.\-]*\.$|[0-9]{1,3}(\.[0-9]{1,3}){3}" | sed 's/\.$//g'`

  ZoneTransfer $NAMESERVERS

}

function Results {
# Numbers of results
#

  echo " [+] Numbers of domains: `cat domains.lst | wc -l`"
  echo " [+] Numbers of IPs: `cat ipaddress.lst | wc -l`"

}

function Usage {
# Function with the sintax of script

  echo "ERROR: Domain name is required"
  echo "Sintax:   $0 <domain>"
  echo -e "Examples: $0 cnn.com\n\t  $0 sun.com"
  exit 1

}

function ZoneTransfer() {
# Loop for zone transfer of all names servers associated with the
# domain target
#

  local I=""
  for I in $@; do

    echo " [+] Testing: $I"
    # dig axfn domain @nameserver --> Zone transfer
    dig axfr $DOMAIN @$I | grep -E "IN" >> tmp

  done

  # If results don't contains "IN" characters, tmp file is blank
  # with 0 bits
  [ ! -s tmp ] && echo "[!] Zone transfers failed!" && rm tmp && exit 2

}

### SCRIPT
# Check number of arguments
[ $# -lt 1 ] || [ $# -gt 1 ] && Usage || DOMAIN=$1

# NameServers function
NameServers

# Filter function
Filter

# Results function
Results

# Delete temporal files
#
echo "[*] Deleting temporal files"
rm -rf tmp *.tmp

### EXIT
# Code Exit:
# 0 -> Normal exit
# 1 -> Usage/No domain defined
# 2 -> Transfer failed
#
echo "[*] REMEMBER: domains.lst and ipaddress.lst files contains this results!"
exit 0

#EOF
##FVE 
