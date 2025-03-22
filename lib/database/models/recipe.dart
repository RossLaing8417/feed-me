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
  final DateTime? createdDateTime;
  final DateTime? lastModifiedDateTime;

  const RecipeModel({
    this.id,
    required this.name,
    required this.description,
    required this.mealTime,
    required this.weekday,
    this.rating = 0,
    this.createdDateTime,
    this.lastModifiedDateTime,
  });

  Map<String, Object?> toMap() {
    return {
      // RecipeFields.id: id,
      RecipeFields.name: name,
      RecipeFields.description: description,
      RecipeFields.mealTime: mealTime,
      RecipeFields.weekday: weekday.toInt(),
      RecipeFields.rating: rating,
      RecipeFields.createdDateTime: createdDateTime?.millisecondsSinceEpoch,
      RecipeFields.lastModifiedDateTime: lastModifiedDateTime?.millisecondsSinceEpoch,
    };
  }
}