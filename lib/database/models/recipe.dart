import 'package:feedme/core/mealtime.dart';
import 'package:feedme/core/weekday.dart';
import 'package:feedme/database/schema/recipe.dart';

class RecipeModel {
  final int? id;
  final String name;
  final String description;
  final MealTime mealTime;
  final Weekday weekday;
  final int rating;
  // final String sourceType            string `gorm:"not null"`
  // final String sourceValue           string `gorm:"not null"`
  // final String frequency             uint8  `gorm:"not null"`

  const RecipeModel({
    this.id,
    required this.name,
    required this.description,
    required this.mealTime,
    required this.weekday,
    this.rating = 0,
  });

  factory RecipeModel.fromMap(Map<String, Object?> map) => RecipeModel(
    id: map[RecipeFields.id] as int?,
    name: map[RecipeFields.name] as String,
    description: map[RecipeFields.description] as String,
    mealTime: map[RecipeFields.mealTime] as MealTime,
    weekday: Weekday.fromDay(map[RecipeFields.weekday] as int),
    rating: map[RecipeFields.rating] as int,
  );

  Map<String, Object?> toMap() {
    return {
      // RecipeFields.id: id,
      RecipeFields.name: name,
      RecipeFields.description: description,
      RecipeFields.mealTime: mealTime,
      RecipeFields.weekday: weekday.toInt(),
      RecipeFields.rating: rating,
    };
  }
}