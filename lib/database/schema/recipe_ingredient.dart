import 'package:feedme/database/schema/ingredient.dart';
import 'package:feedme/database/schema/measurement.dart';
import 'package:feedme/database/schema/recipe.dart';

class RecipeIngredientFields {
  static const id = "id";
  static const recipeId = "recipe_id";
  static const ingredientId = "ingredient_id";
  static const measurementId = "measurement_id";
  static const label = "label";
  static const description = "description";
  static const measurementValue = "measurementValue";

  static const columns = [
    id,
    recipeId,
    ingredientId,
    measurementId,
    label,
    description,
    measurementValue,
  ];
}

class RecipeIngredientTable {
  static const tableName = "recipe_ingredients";
  static const idType = "INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT NOT NULL";
  static const intType = "INTEGER NOT NULL";
  static const textType = "TEXT NOT NULL";
  static const doubleType = "REAL NOT NULL";

  static String onCreate(int version) {
    switch (version) {
      case 1: return """
        CREATE TABLE $tableName (
          ${RecipeIngredientFields.id} $idType,
          ${RecipeIngredientFields.recipeId} $intType,
          ${RecipeIngredientFields.ingredientId} $intType,
          ${RecipeIngredientFields.measurementId} $textType,
          ${RecipeIngredientFields.label} $textType,
          ${RecipeIngredientFields.description} $textType,
          ${RecipeIngredientFields.measurementValue} $doubleType CHECK(${RecipeIngredientFields.measurementValue} >= 0.0),
          CONSTRAINT fk_${RecipeIngredientFields.recipeId     } FOREIGN KEY (${RecipeIngredientFields.recipeId     }) REFERENCES ${RecipeTable.tableName     } (${RecipeFields.id     }) ON DELETE RESTRICT,
          CONSTRAINT fk_${RecipeIngredientFields.ingredientId } FOREIGN KEY (${RecipeIngredientFields.ingredientId }) REFERENCES ${IngredientTable.tableName } (${IngredientFields.id }) ON DELETE RESTRICT,
          CONSTRAINT fk_${RecipeIngredientFields.measurementId} FOREIGN KEY (${RecipeIngredientFields.measurementId}) REFERENCES ${MeasurementTable.tableName} (${MeasurementFields.id}) ON DELETE RESTRICT
        ) ;
      """;
      default:
        assert(false, "Unimplemented create version: $version");
    }
    return "";
  }

  static String onUpgrade(int version) {
    switch (version) {
      default:
        assert(false, "Unimplemented upgrade version: $version");
    }
    return "";
  }
}