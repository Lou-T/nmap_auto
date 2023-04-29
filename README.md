# nmap_auto

SYNTAX: sudo ./nmap_auto.sh [IP/host] -[q] [-u]

This tool automates the sequence of a quick port scan, full port scan, subsequent enumeration scan of all open ports discovered, and UDP scan. A quick port scan and UDP scan are not included by default. To include them, use the -q and -u flags, respectively.

The results of the enumeration scan and UDP scan are stored in a directory named after the target IP/host. Results of the quick scan are not stored as this initial scan is designed to give the tester a quick idea of where to begin probing while more thorough scans are being completed.

Note: The script requires sudo privileges to perform OS and UDP scans, as well as to write reformatted scan results to a file. This is the method by which the script extracts open ports from the initial full port scan, reformats them, and inserts them into the subsequent enumeration scan.
