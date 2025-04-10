import 'package:feedme/database/database.dart';
import 'package:feedme/views/home.dart';
import 'package:feedme/views/ingredients.dart';
import 'package:feedme/views/meal_planner.dart';
import 'package:feedme/views/measurements.dart';
import 'package:feedme/views/recipes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int index = 0;
  late final List<Widget> page;

  @override
  void initState() {
    page = [AppHomeView(), AppMealPlannerView(), AppRecipesView()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              switch (value) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppIngredientsView(),
                    ),
                  );
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppMeasurementsView(),
                    ),
                  );
                case 99:
                  setState(() {
                    AppDatabase.reset();
                  });
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem<int>(value: 0, child: Text("Ingredients")),
                  PopupMenuItem<int>(value: 1, child: Text("Measurements")),
                  if (kDebugMode)
                    PopupMenuItem<int>(value: 99, child: Text("Reset")),
                ],
          ),
        ],
      ),
      body: page[index],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 28,
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(
              index == 0 ? CupertinoIcons.house_fill : CupertinoIcons.house,
            ),
          ),
          BottomNavigationBarItem(
            label: "Meal Planner",
            icon: Icon(
              index == 1
                  ? CupertinoIcons.calendar_today
                  : CupertinoIcons.calendar,
            ),
          ),
          BottomNavigationBarItem(
            label: "Recipes",
            icon: Icon(
              index == 2 ? CupertinoIcons.book_fill : CupertinoIcons.book,
            ),
          ),
        ],
      ),
    );
  }
}
