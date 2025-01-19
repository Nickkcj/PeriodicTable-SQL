#!/bin/bash

# Check if an argument was provided
if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 1
fi

# Input element (atomic number, symbol, or name)
element_input="$1"

# Check if the input is a number (atomic number)
if [[ "$element_input" =~ ^[0-9]+$ ]]; then
  # Query for atomic number
  result=$(psql -U freecodecamp -d periodic_table -t -c "
    SELECT 
      e.atomic_number, 
      e.symbol, 
      e.name, 
      p.atomic_mass, 
      p.melting_point_celsius, 
      p.boiling_point_celsius, 
      p.type
    FROM 
      elements e
    JOIN 
      properties p ON e.atomic_number = p.atomic_number
    WHERE 
      e.atomic_number = '$element_input';")
else
  # Query for symbol or name (non-numeric input)
  result=$(psql -U freecodecamp -d periodic_table -t -c "
    SELECT 
      e.atomic_number, 
      e.symbol, 
      e.name, 
      p.atomic_mass, 
      p.melting_point_celsius, 
      p.boiling_point_celsius, 
      p.type
    FROM 
      elements e
    JOIN 
      properties p ON e.atomic_number = p.atomic_number
    WHERE 
      e.symbol = '$element_input' OR e.name ILIKE '$element_input';")
fi

# Check if a result was found
if [ -z "$result" ]; then
  echo "I could not find that element in the database."
  exit 1
fi

# Extract individual pieces of data
atomic_number=$(echo "$result" | cut -d '|' -f 1 | xargs)
symbol=$(echo "$result" | cut -d '|' -f 2 | xargs)
name=$(echo "$result" | cut -d '|' -f 3 | xargs)
atomic_mass=$(echo "$result" | cut -d '|' -f 4 | xargs)
melting_point=$(echo "$result" | cut -d '|' -f 5 | xargs)
boiling_point=$(echo "$result" | cut -d '|' -f 6 | xargs)
type=$(echo "$result" | cut -d '|' -f 7 | xargs)

# Format the output string
echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."

