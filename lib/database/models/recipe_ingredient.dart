import 'package:feedme/database/schema/recipe_ingredient.dart';

class RecipeIngredientModel {
  final int? id;
  final int recipeId;
  final int ingredientId;
  final int measurementId;
  final String label;
  final String description;
  final double measurementValue;

  const RecipeIngredientModel({
    this.id,
    required this.recipeId,
    required this.ingredientId,
    required this.measurementId,
    required this.label,
    required this.description,
    required this.measurementValue,
  });

  factory RecipeIngredientModel.fromMap(Map<String, Object?> map) => RecipeIngredientModel(
    id: map[RecipeIngredientFields.id] as int?,
    recipeId: map[RecipeIngredientFields.recipeId] as int,
    ingredientId: map[RecipeIngredientFields.ingredientId] as int,
    measurementId: map[RecipeIngredientFields.measurementId] as int,
    label: map[RecipeIngredientFields.label] as String,
    description: map[RecipeIngredientFields.description] as String,
    measurementValue: map[RecipeIngredientFields.measurementValue] as double,
  );

  Map<String, Object?> toMap() {
    return {
      // RecipeIngredientFields.id: id,
      RecipeIngredientFields.recipeId: recipeId,
      RecipeIngredientFields.ingredientId: ingredientId,
      RecipeIngredientFields.measurementId: measurementId,
      RecipeIngredientFields.label: label,
      RecipeIngredientFields.description: description,
      RecipeIngredientFields.measurementValue: measurementValue,
    };
  }
}