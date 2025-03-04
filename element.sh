#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if no argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

# Check if input is a number (atomic number)
if [[ "$1" =~ ^[0-9]+$ ]]
then
  # If number, search by atomic_number
  RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = '$1';")
else
  # If string (symbol or name), search by symbol or name
  RESULT=$($PSQL "SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE symbol ILIKE '$1' OR name ILIKE '$1';")
fi

# Trim result to ensure no extra spaces
RESULT=$(echo "$RESULT" | xargs)

# Check if result exists
if [[ -z "$RESULT" ]]
then
  # Print error message and exit
  echo "I could not find that element in the database."
else
  # Print element information only if result exists
  echo "$RESULT" | while IFS='|' read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING
  do
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  done
fi