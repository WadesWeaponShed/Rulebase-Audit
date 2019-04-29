DATE=$(date +%m/%d/%Y -d '365 days ago')
DATE2=$(date +%m-%d-%Y -d '365 days ago')
EPOC=$(date -d "$DATE" +%s%N | cut -b1-13)

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

printf "\nDoes Your Policy Contain Section Title Headers?[y/n]\n"
read SECHEAD

if [ "$SECHEAD" = "y" ]; then
printf "\nSearching for Rules older than $DATE in $POL_NAME.\n"
for I in $(seq 0 500 $TOTAL)
do
  mgmt_cli -r true -d $DOMAIN show access-rulebase offset $I limit 500 name "$POL_NAME" details-level "standard" use-object-dictionary true --format json | jq --raw-output --arg EPOC "$EPOC" '.rulebase[]| .rulebase[]| select(."meta-info"."creation-time".posix <= '$EPOC' ) | ."rule-number"' >> old_rules.txt
done

elif [ "$SECHEAD" = "n" ]; then
  printf "\nSearching for Rules older than $DATE in $POL_NAME.\n"
  for I in $(seq 0 500 $TOTAL)
  do
    mgmt_cli -r true -d $DOMAIN show access-rulebase offset $I limit 500 name "$POL_NAME" details-level "standard" use-object-dictionary true --format json | jq --raw-output --arg EPOC "$EPOC" '.rulebase[]| select(."meta-info"."creation-time".posix <= '$EPOC' ) | ."rule-number"' >> old_rules.txt
  done
fi

while read  LINE;
do
  echo "Rule Number: $LINE" >>$POL2-rules-older-than-$DATE2.txt
  mgmt_cli -r true -d $DOMAIN show access-rule layer "$POL_NAME" rule-number $LINE --format json >>$POL2-rules-older-than-$DATE2.txt
done < old_rules.txt
rm old_rules.txt

printf "\nOlder rules are located in $POL2-rules-older-than-$DATE2.txt\n"
