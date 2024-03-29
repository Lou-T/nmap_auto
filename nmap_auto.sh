#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

if [[ "$1" == "-q" && -n "$2" ]] || [[ "$1" == "-u" && -n "$2" ]]; then
  echo ""
  echo "ERROR: IP/host must be the first argument"
  echo ""
  echo "SYNTAX: sudo ./nmap_auto.sh [IP/host] [-q] [-u]"
  echo ""
  echo -e "\t -q    Include Quick Port Scan"
  echo -e "\t -u    Include UDP Scan"
  exit 1
fi

if [[ -z "$1" || "$1" == "-q" || "$1" == "-u" ]]; then
    echo ""
    echo "SYNTAX: sudo ./nmap_auto.sh [IP/host] [-q] [-u]"
    echo ""
    echo -e "\t -q    Include Quick Port Scan"
    echo -e "\t -u    Include UDP Scan"
    exit 1
fi

if [[ $1 == "-h" ]]; then
    echo ""
    echo "SYNTAX: sudo ./nmap_auto.sh [IP/host] [-q] [-u]"
    echo ""
    echo -e "\t -q    Include Quick Port Scan"
    echo -e "\t -u    Include UDP Scan"
    exit 0
fi

ip_address="$1"
quick_scan=false
udp_scan=false

if [[ "$@" =~ "-q" ]]; then
    quick_scan=true
fi

if [[ "$@" =~ "-u" ]]; then
    udp_scan=true
fi

if [ "$quick_scan" = true ]; then
    echo ""
    echo -e "${GREEN}------------------------Performing Quick Port Scan------------------------------"
    echo -e "${NC}"

    nmap -Pn -T3 $ip_address
fi

function cleanup {
    rm -f nmap_initial.nmap input.txt 
}

trap cleanup EXIT

echo ""
echo -e "${GREEN}------------------------Performing Full Port Scan-------------------------------"
echo -e "${NC}"

nmap -Pn -T3 -p- --min-rate 100 -oN nmap_initial.nmap $ip_address # > /dev/null 2>&1

cat nmap_initial.nmap | grep "^ *[0-9]" | awk -F'/' '{print $1}' | tr '\\\\\\\\\\\\\\\\\\\\\\\\n' ',' | sed 's/,$//' > input.txt
rm nmap_initial.nmap

numbers=($(cat input.txt))

numbers=($(echo "${numbers[@]}" | tr ' ' '\\\\\\\\n' | tr '\\\\\\\\n' ' '))

rm input.txt

echo "The following ports are open: "
printf "%s," "${numbers[@]}" | sed 's/,$//'

ports=$(printf "%s," "${numbers[@]}" | sed 's/,$//')

if [ -d "$ip_address" ]; then
    rm -r "$ip_address"
fi

mkdir nmap_$ip_address

echo ""
echo ""
echo -e "${GREEN}------------------------Enumerating Services on Open Ports----------------------"
echo -e "${NC}"

nmap -Pn -sV -sC -O -p $ports -T3 -oN nmap_$ip_address/enumeration_results $ip_address > /dev/null
cat "nmap_$ip_address/enumeration_results"

echo ""
echo -e "${YELLOW}Results of enumeration scan have been stored in $ip_address"
echo -e "${NC}"

if [ "$udp_scan" = true ]; then
    echo -e "${GREEN}------------------------Performing UDP Port Scan--------------------------------"
    echo -e "${NC}"

    nmap -sU -T3 $ip_address -oN nmap_$ip_address/UDP_results
    echo ""

    echo -e "${YELLOW}Results of UDP scan have been stored in $ip_address"
    echo ""

fi

echo -e "${RED}------------------------All Scans Completed-------------------------------------" 
