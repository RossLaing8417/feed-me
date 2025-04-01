import 'package:feedme/database/schema/recipe_ingredient.dart';

class RecipeIngredientModel {
  final int? id;
  final int recipeId;
  final int ingredientId;
  final String label;
  final String description;
  final int measurementId;
  final double measurementValue;

  const RecipeIngredientModel({
    this.id,
    required this.recipeId,
    required this.ingredientId,
    required this.label,
    required this.description,
    required this.measurementId,
    required this.measurementValue,
  });

  factory RecipeIngredientModel.fromMap(Map<String, Object?> map) =>
      RecipeIngredientModel(
        id: map[RecipeIngredientFields.id] as int?,
        recipeId: map[RecipeIngredientFields.recipeId] as int,
        ingredientId: map[RecipeIngredientFields.ingredientId] as int,
        label: map[RecipeIngredientFields.label] as String,
        description: map[RecipeIngredientFields.description] as String,
        measurementId: map[RecipeIngredientFields.measurementId] as int,
        measurementValue:
            map[RecipeIngredientFields.measurementValue] as double,
      );

  Map<String, Object?> toMap() {
    return {
      RecipeIngredientFields.recipeId: recipeId,
      RecipeIngredientFields.ingredientId: ingredientId,
      RecipeIngredientFields.label: label,
      RecipeIngredientFields.description: description,
      RecipeIngredientFields.measurementId: measurementId,
      RecipeIngredientFields.measurementValue: measurementValue,
    };
  }
}
