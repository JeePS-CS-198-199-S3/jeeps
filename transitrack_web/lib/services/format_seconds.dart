String formatSeconds(double seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;
  int remainingSeconds = (seconds % 60).round();

  String hoursStr = hours.toString().padLeft(2, '0');
  String minutesStr = minutes.toString().padLeft(2, '0');
  String secondsStr = remainingSeconds.toString().padLeft(2, '0');

  return '${hours != 0
      ? "$hoursStr:"
      : ""}'

      '${minutes != 0 && hours == 0
      ? "$minutesStr:"
      : ""}'

      '$secondsStr';
}