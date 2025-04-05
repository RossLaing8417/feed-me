import 'package:feedme/database/schema/meal_plan.dart';

class MealPlanModel {
  final int? id;
  final int recipeId;
  final DateTime mealDate;
  final String notes;

  const MealPlanModel({
    this.id,
    required this.recipeId,
    required this.mealDate,
    required this.notes,
  });

  factory MealPlanModel.fromMap(Map<String, Object?> map) => MealPlanModel(
    id: map[MealPlanFields.id] as int?,
    recipeId: map[MealPlanFields.recipeId] as int,
    mealDate: DateTime.fromMicrosecondsSinceEpoch(
      map[MealPlanFields.mealDate] as int,
    ),
    notes: map[MealPlanFields.notes] as String,
  );

  Map<String, Object?> toMap() {
    return {
      MealPlanFields.recipeId: recipeId,
      MealPlanFields.mealDate: mealDate.millisecondsSinceEpoch,
      MealPlanFields.notes: notes,
    };
  }
}
