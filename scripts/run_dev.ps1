Get-Content .env.local | ForEach-Object {
  if ($_ -match "=") {
    $name, $value = $_ -split "="
    Set-Item -Path env:$name -Value $value
  }
}

flutter run `
  --dart-define=WEATHER_API_KEY=$env:WEATHER_API_KEY `
  --dart-define=ENV=$env:ENV
