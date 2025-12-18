#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

INPUT="$1"

# Check if atomimic number || symbol/name
if [[ $INPUT =~ ^[0-9]+$ ]]
then
  WHERE_CLAUSE="e.atomic_number = $INPUT"
else
  # Lower case-sensitive
  WHERE_CLAUSE="LOWER(e.symbol) = LOWER('$INPUT') OR LOWER(e.name) = LOWER('$INPUT')"
fi

RESULT=$($PSQL "
SELECT
  e.atomic_number,
  e.name,
  e.symbol,
  t.type,
  p.atomic_mass,
  p.melting_point_celsius,
  p.boiling_point_celsius
FROM elements e
JOIN properties p USING(atomic_number)
JOIN types t USING(type_id)
WHERE $WHERE_CLAUSE
LIMIT 1;
")

if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

IFS="|" read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL <<< "$RESULT"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."

