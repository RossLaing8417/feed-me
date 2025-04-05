class MealPlanFields {
  /// Unique identifier
  static const id = "id";

  /// Meal recipe
  static const recipeId = "recipe_id";

  /// Planned date of the meal
  static const mealDate = "meal_date";

  /// Notes
  static const notes = "notes";

  static const columns = [id, recipeId, mealDate, notes];
}

class MealPlanTable {
  static const name = "meal_plan";
  static const idType = "INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT NOT NULL";
  static const intType = "INTEGER NOT NULL";
  static const dateType = "INTEGER NOT NULL";
  static const textType = "TEXT NOT NULL";

  static String onCreate(int version) {
    switch (version) {
      case 1:
        return """
        CREATE TABLE $name (
          ${MealPlanFields.id} $idType
        , ${MealPlanFields.recipeId} $intType
        , ${MealPlanFields.mealDate} $dateType
        , ${MealPlanFields.notes} $textType
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
