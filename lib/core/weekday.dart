class Weekday {
  int _weekdays = 0;
  Weekday._internal(this._weekdays);

  factory Weekday.fromInt(int weekdays) => Weekday._internal(weekdays);

  factory Weekday.fromDay(int day) {
    assert(day > 0 && day < 8, "Day must be a value from 1 to 7");
    return Weekday._internal(1 << (day - 1));
  }
  static Weekday get none => Weekday._internal(0);
  static Weekday get monday => Weekday.fromDay(DateTime.monday);
  static Weekday get tuesday => Weekday.fromDay(DateTime.tuesday);
  static Weekday get wednesday => Weekday.fromDay(DateTime.wednesday);
  static Weekday get thursday => Weekday.fromDay(DateTime.thursday);
  static Weekday get friday => Weekday.fromDay(DateTime.friday);
  static Weekday get saturday => Weekday.fromDay(DateTime.saturday);
  static Weekday get sunday => Weekday.fromDay(DateTime.sunday);
  static Weekday get weekdays {
    final weekday = Weekday.monday;
    weekday.toggleTuesday();
    weekday.toggleWednesday();
    weekday.toggleThursday();
    weekday.toggleFriday();
    return weekday;
  }
  static Weekday get weekends {
    final weekday = Weekday.saturday;
    weekday.toggleSunday();
    return weekday;
  }

  toggleDay(int day, [bool? set]) {
    assert(day > 0 && day < 8, "Day must be a value from 1 to 7");
    if (set == null) {
      _weekdays ^= 1 << (day - 1);
    } else if (set) {
      _weekdays |= 1 << (day - 1);
    } else {
      _weekdays &= ~(1 << (day - 1));
    }
  }
  toggleMonday([bool? set]) => toggleDay(DateTime.monday, set);
  toggleTuesday([bool? set]) => toggleDay(DateTime.tuesday, set);
  toggleWednesday([bool? set]) => toggleDay(DateTime.wednesday, set);
  toggleThursday([bool? set]) => toggleDay(DateTime.thursday, set);
  toggleFriday([bool? set]) => toggleDay(DateTime.friday, set);
  toggleSaturday([bool? set]) => toggleDay(DateTime.saturday, set);
  toggleSunday([bool? set]) => toggleDay(DateTime.sunday, set);
  toggleWeekdays([bool? set]) {
    toggleMonday(set);
    toggleTuesday(set);
    toggleWednesday(set);
    toggleThursday(set);
    toggleFriday(set);
  }
  toggleWeekends([bool? set]) {
    toggleSaturday(set);
    toggleSunday(set);
  }
  toggleEveryDay([bool? set]) {
    toggleWeekdays(set);
    toggleWeekends(set);
  }

  hasDay(int day) {
    assert(day > 0 && day < 8, "Day must be a value from 1 to 7");
    return ((_weekdays >> (day - 1)) & 1) == 1;
  }
  hasNone() => _weekdays == 0;
  hasMonday() => hasDay(DateTime.monday);
  hasTuesday() => hasDay(DateTime.tuesday);
  hasWednesday() => hasDay(DateTime.wednesday);
  hasThursday() => hasDay(DateTime.thursday);
  hasFriday() => hasDay(DateTime.friday);
  hasSaturday() => hasDay(DateTime.saturday);
  hasSunday() => hasDay(DateTime.sunday);
  anyWeekday() => hasMonday() || hasTuesday() || hasWednesday()
      || hasThursday() || hasFriday();
  anyWeekend() => hasSaturday() || hasSunday();
  allWeekday() => hasMonday() && hasTuesday() && hasWednesday()
      && hasThursday() && hasFriday();
  allWeekend() => hasSaturday() && hasSunday();
  hasEveryDay() => allWeekday() && allWeekend();

  toInt() => _weekdays;

  @override
  String toString() {
    if (_weekdays == 0) return "None";
    if (hasEveryDay()) return "Every Day";
    List<String> string = [];
    if (allWeekday()) {
      string.add("Weekdays");
    } else {
      if (hasMonday()) string.add("Monday");
      if (hasTuesday()) string.add("Tuesday");
      if (hasWednesday()) string.add("Wednesday");
      if (hasThursday()) string.add("Thursday");
      if (hasFriday()) string.add("Friday");
      if (hasSaturday()) string.add("Saturday");
      if (hasSunday()) string.add("Sunday");
    }
    if (allWeekend()) {
      string.add("Weekends");
    } else {
      if (hasSaturday()) string.add("Saturday");
      if (hasSunday()) string.add("Sunday");
    }
    return string.join(",");
  }
}