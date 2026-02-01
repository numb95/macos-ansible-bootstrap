#!/bin/bash

# Define the city
CITY="Berlin"

# Fetch the weather information from wttr.in
WEATHER=$(curl -s "https://wttr.in/${CITY}?format=%C+%t+%w+%h")

# Display the weather information
if [ -n "$WEATHER" ]; then
    echo "${CITY}: $WEATHER"
else
    echo "Failed to fetch weather data for ${CITY}."
fi
