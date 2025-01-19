#!/bin/bash

# Check if an argument was provided
if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 0  # Exit the script if no argument is provided
fi

# Query the database based on the argument type (atomic number, symbol, or name)
if [[ "$1" =~ ^[0-9]+$ ]]; then
  element=$(psql -U freecodecamp -d periodic_table -t -c "SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type 
                                        FROM elements e 
                                        INNER JOIN properties p ON e.atomic_number = p.atomic_number 
                                        INNER JOIN types t ON p.type_id = t.type_id 
                                        WHERE e.atomic_number = $1 LIMIT 1;")
elif [[ "$1" =~ ^[A-Za-z]+$ ]]; then
  element=$(psql -U freecodecamp -d periodic_table -t -c "SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type 
                                        FROM elements e 
                                        INNER JOIN properties p ON e.atomic_number = p.atomic_number 
                                        INNER JOIN types t ON p.type_id = t.type_id 
                                        WHERE e.symbol = '$1' OR e.name = '$1' LIMIT 1;")
else
  echo "I could not find that element in the database."
  exit 0
fi

# Check if an element was found
if [ -z "$element" ]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Parsing the result and assigning values to variables
IFS='|' read -r atomic_number symbol name atomic_mass melting_point boiling_point type <<<"$element"

# Trim leading/trailing spaces from each variable (to handle formatting issues)
atomic_number=$(echo "$atomic_number" | xargs)
symbol=$(echo "$symbol" | xargs)
name=$(echo "$name" | xargs)
atomic_mass=$(echo "$atomic_mass" | xargs)
melting_point=$(echo "$melting_point" | xargs)
boiling_point=$(echo "$boiling_point" | xargs)
type=$(echo "$type" | xargs)

# Now output the formatted string
echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."




