#!/usr/bin/env bash
#
# Generate credentials json structure with random passwords on the following format:
# [
#   { "name": "u1", "pass": "p1" },
#   { "name": "u2", "pass": "p2" }
# ]
#
set -e
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <user1> [<user2>] ..."
    exit 1
fi

# $1: length
randpw() { dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 | rev | cut -b 2- | rev | tr -dc _A-Z-a-z-0-9 | head -c$1; }

# $1: username, $2: passwordLength
createUserCredentials() { echo -n '{ "name": "'"$1"'", "pass": "'"`randpw $2`"'" }'; }

echo '['
while test $# -gt 0
do
  echo -n '  ' `createUserCredentials $1 15`
  if [[ "$#" -gt 1 ]]; then
    echo ','
  else
    echo
  fi
  shift
done
echo ']'
