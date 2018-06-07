#!/bin/bash
list_environments=()
aws ec2 describe-network-interfaces --profile kainosmap --output text | grep ASSOCIATION > test.txt
while read -r p; do
  set -- $p
  list_environments+=($4)
done <test.txt
printf "%s\n" "${list_environments[@]}" > tymczas.txt
awk 'NR%2==0' tymczas.txt > remove_duplicats
sed '/34.237.145.7/d' remove_duplicats > no_jenkins_environments
declare -i i=0;
while read -r p; do
  declare -i y=i+1;
  environment=$(sed "${y}q;d" no_jenkins_environments)
  if [ -z $environment ]; then
    echo "Only $[i] members out of $(wc -l < members) got assigned envs. Fix that!"
    break;
  fi
  i=i+1;
  echo -e "Hello dear geek,\n\n this is your environment's URL: http://${environment}:8080\n\n Database connection details\n user: postgres \n password: mysecretpassword \n port: 5432 \n\n Address where you can find Jenkins: http://34.237.145.7:8080 \n \nuser: workshops\n password: work123\n\n Cheers mate, have a fruitful day! \n Aga & Michal" | mail  -s "Kainos map - Jmeter Workshops" $p
  echo "Member: $p, Env: $environment"
done <members
