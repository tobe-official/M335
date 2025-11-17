double calculateDistanceKm(int steps, double stepLengthMeters) {
  if (steps < 0 || stepLengthMeters <= 0) return 0;
  return (steps * stepLengthMeters) / 1000;
}

double calculatePaceKmH(double km, int minutes) {
  if (minutes <= 0 || km <= 0) return 0;
  return km / (minutes / 60);
}
