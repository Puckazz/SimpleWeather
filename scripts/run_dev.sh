#!/bin/bash

# Load env
export $(grep -v '^#' .env.local | xargs)

flutter run \
  --dart-define=WEATHER_API_KEY=$WEATHER_API_KEY \
  --dart-define=ENV=$ENV
