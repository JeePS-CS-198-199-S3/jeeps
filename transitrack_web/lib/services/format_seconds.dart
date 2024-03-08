String formatSeconds(double seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = (seconds % 60).round();

  if (hours > 0) {
    return "$hours ${hours > 1?"hrs":"hr"}";
  } else if (minutes > 0) {
    return "$minutes ${minutes > 1?"mins":"min"}";
  } else {
    return "< 1 min";
  }
}