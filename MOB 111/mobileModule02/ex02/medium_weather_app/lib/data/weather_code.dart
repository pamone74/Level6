class WeatherCode {
  const WeatherCode._();

  static String description(int code) => switch (code) {
    0 => 'Clear sky',
    1 => 'Mainly clear',
    2 => 'Partly cloudy',
    3 => 'Overcast',
    45 || 48 => 'Fog',
    51 => 'Light drizzle',
    53 => 'Moderate drizzle',
    55 => 'Dense drizzle',
    56 || 57 => 'Freezing drizzle',
    61 => 'Slight rain',
    63 => 'Moderate rain',
    65 => 'Heavy rain',
    66 || 67 => 'Freezing rain',
    71 => 'Slight snow',
    73 => 'Moderate snow',
    75 => 'Heavy snow',
    77 => 'Snow grains',
    80 => 'Slight rain showers',
    81 => 'Moderate rain showers',
    82 => 'Violent rain showers',
    85 || 86 => 'Snow showers',
    95 => 'Thunderstorm',
    96 || 99 => 'Thunderstorm with hail',
    _ => 'Unknown conditions',
  };
}
