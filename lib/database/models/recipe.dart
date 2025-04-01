import 'package:feedme/core/mealtime.dart';
import 'package:feedme/core/weekday.dart';
import 'package:feedme/database/schema/recipe.dart';

class RecipeModel {
  final int? id;
  final String name;
  final String description;
  final String cookingTime;
  final MealTime mealTime;
  final Weekday weekday;
  final int rating;
  final int frequency;

  const RecipeModel({
    this.id,
    required this.name,
    required this.description,
    required this.cookingTime,
    required this.mealTime,
    required this.weekday,
    required this.rating,
    required this.frequency,
  });

  factory RecipeModel.fromMap(Map<String, Object?> map) => RecipeModel(
    id: map[RecipeFields.id] as int?,
    name: map[RecipeFields.name] as String,
    description: map[RecipeFields.description] as String,
    cookingTime: map[RecipeFields.cookingTime] as String,
    mealTime: MealTime.values[map[RecipeFields.mealTime] as int],
    weekday: Weekday.fromInt(map[RecipeFields.weekday] as int),
    rating: map[RecipeFields.rating] as int,
    frequency: map[RecipeFields.frequency] as int,
  );

  Map<String, Object?> toMap() {
    return {
      RecipeFields.name: name,
      RecipeFields.description: description,
      RecipeFields.cookingTime: cookingTime,
      RecipeFields.mealTime: mealTime.index,
      RecipeFields.weekday: weekday.toInt(),
      RecipeFields.rating: rating,
      RecipeFields.frequency: frequency,
    };
  }
}
