import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AppMealPlannerView extends StatefulWidget {
  const AppMealPlannerView({super.key});

  @override
  State<AppMealPlannerView> createState() => _AppMealPlannerViewState();
}

class _AppMealPlannerViewState extends State<AppMealPlannerView> {
  late DateTime startOfThisWeek;
  late DateTime startOfNextWeek;

  @override
  void initState() {
    final now = DateTime.now();
    startOfThisWeek = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1) % 7,
    );
    startOfNextWeek = startOfThisWeek.add(Duration(days: 7));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: Card(
              child: Column(
                children: [
                  Text(
                    "This Week",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: AppWeekPlanner(startDate: startOfThisWeek),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: Column(
                children: [
                  Text(
                    "Next Week",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: AppWeekPlanner(startDate: startOfNextWeek),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 64.0 + 8.0),
        ],
      ),
    );
  }
}

class AppWeekPlanner extends StatefulWidget {
  final DateTime startDate;

  const AppWeekPlanner({super.key, required this.startDate});

  @override
  State<AppWeekPlanner> createState() => _AppWeekPlannerState();
}

class _AppWeekPlannerState extends State<AppWeekPlanner> {
  late int? _todayIndex;

  @override
  void initState() {
    final now = DateTime.now();
    _todayIndex =
        widget.startDate.isAfter(now)
            ? null
            : now.difference(widget.startDate).inDays;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      scrollDirection: Axis.horizontal,
      initialScrollIndex: _todayIndex ?? 0,
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = widget.startDate.add(Duration(days: index));
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: _todayIndex != null && index == _todayIndex ? Theme.of(context).primaryColor : null,
            ),
            width: 128.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  DateFormat.MMM().format(date),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  DateFormat(DateFormat.ABBR_WEEKDAY).format(date),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  DateFormat("dd").format(date),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
