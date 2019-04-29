This script can be used to audit a rulebase based on a previous date. By default it is setup to check for rules 365 days prior to the current system date. If you want to change the amount of days just change it in the first 2 lines of the script.


## How to Use ##
- cp script over to mgmt station (this script is intended to run directly on the mgmt station)
- execute ./audit.sh
   - script will ask for IP of SMS or Domain of MDS you wish to search.
   - Will ask for the Access Policy you want to checking
   - Will ask if your policy has Section Tiles
- Output will be in a text file $POL2-rules-older-than-$DATE2.txt
