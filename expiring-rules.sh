DATE=$(date +%m/%d/%Y -d '+7 days')
DATE2=$(date +%m-%d-%Y -d '+7 days')
EPOC=$(date -d "$DATE" +%s%N | cut -b1-13)

FILE=time-object-name.txt
if test -f "$FILE"; then
    rm $FILE
fi

FILE2=old_rules.txt
if test -f "$FILE2"; then
    rm $FILE2
fi

printf "\nWhat is the IP address or Name of the Domain or SMS you want to check?\n"
read DOMAIN

printf "\nListing Access Policy Package Names\n"
mgmt_cli -r true -d $DOMAIN show access-layers limit 500 --format json | jq --raw-output '."access-layers"[] | (.name)'

printf "\nWhat is the Policy Package Name?\n"
read POL_NAME
POL2=$(echo $POL_NAME | tr -d ' ')

printf "\nDetermining Rulesbase Size\n"
TOTAL=$(mgmt_cli -r true -d $DOMAIN show access-rulebase name "$POL_NAME" --format json |jq '.total')
printf "There are $TOTAL rules in $POL_NAME\n"

printf "\nSearching for Rules older that are withing 7 days of expiring in $POL_NAME.\n"
mgmt_cli -r true show times details-level full limit 500 --format json | jq --raw-output '.objects[] | select(.end.posix <= 1565240400000 and .end.posix==0|not ) |.name' >>time-object-name.txt
  for line in $(cat time-object-name.txt)
    do
      mgmt_cli -r true -d $DOMAIN show access-rulebase limit 500 name "$POL_NAME" details-level "standard" use-object-dictionary true filter "$line" --format json >> old_rules.txt
done
