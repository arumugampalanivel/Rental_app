class RentDateUtils {
  static List<String> generateMonthList(String lastPaidMonthStr) {
    final now = DateTime.now();
    final months = <String>[];

    // If no last paid month → everything is pending from start of current tenancy
    if (lastPaidMonthStr.isEmpty || lastPaidMonthStr == "null") {
      return months;
    }

    // Parse: "January 2025"
    final parts = lastPaidMonthStr.split(" ");
    final monthName = parts[0];
    final year = int.parse(parts[1]);

    final month = _monthNumber(monthName);
    DateTime paidDate = DateTime(year, month);

    // Start from next month after last paid
    DateTime check = DateTime(paidDate.year, paidDate.month + 1);

    // Loop month by month until current month
    while (check.year < now.year ||
        (check.year == now.year && check.month <= now.month)) {
      months.add(_monthString(check));
      check = DateTime(check.year, check.month + 1);
    }

    return months;
  }

  static int _monthNumber(String name) {
    const months = {
      "January": 1,
      "February": 2,
      "March": 3,
      "April": 4,
      "May": 5,
      "June": 6,
      "July": 7,
      "August": 8,
      "September": 9,
      "October": 10,
      "November": 11,
      "December": 12,
    };
    return months[name] ?? 1;
  }

  static String _monthString(DateTime d) {
    const names = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return "${names[d.month]} ${d.year}";
  }
}
