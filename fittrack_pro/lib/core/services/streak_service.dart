class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final bool hasWorkoutToday;
  final Set<String> activeDates; // Stored as 'YYYY-MM-DD'

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.hasWorkoutToday,
    required this.activeDates,
  });
}

class StreakService {
  static String formatDateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static StreakResult calculateStreak(List<DateTime> completionDates) {
    if (completionDates.isEmpty) {
      return const StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        hasWorkoutToday: false,
        activeDates: {},
      );
    }

    // Normalize unique sorted dates
    final Set<String> dateStrings = {};
    for (final d in completionDates) {
      dateStrings.add(formatDateKey(d));
    }

    final sortedDates = dateStrings.map((s) => DateTime.parse(s)).toList()
      ..sort((a, b) => b.compareTo(a)); // Descending order (newest first)

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayKey = formatDateKey(today);
    final hasWorkoutToday = dateStrings.contains(todayKey);

    // Calculate current streak
    int currentStreak = 0;
    DateTime checkDate = hasWorkoutToday ? today : yesterday;

    while (dateStrings.contains(formatDateKey(checkDate))) {
      currentStreak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Calculate longest streak
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? prevDate;

    // Ascending order for longest streak calculation
    final ascendingDates = sortedDates.reversed.toList();
    for (final d in ascendingDates) {
      if (prevDate == null) {
        tempStreak = 1;
      } else {
        final diffDays = d.difference(prevDate).inDays;
        if (diffDays == 1) {
          tempStreak++;
        } else if (diffDays > 1) {
          tempStreak = 1;
        }
      }
      prevDate = d;
      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
    }

    return StreakResult(
      currentStreak: currentStreak,
      longestStreak: longestStreak > currentStreak ? longestStreak : currentStreak,
      hasWorkoutToday: hasWorkoutToday,
      activeDates: dateStrings,
    );
  }
}
