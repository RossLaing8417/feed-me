class RecipeFields {
  /// Unique identifier
  static const id = "id";
  /// Recipe name
  static const name = "name";
  /// Recipe description
  static const description = "description";
  /// Approximate total time it takes to prepare and cook
  static const cookingTime = "cooking_time";
  /// Times of day the recipe if for (breakfast, lunch, supper)
  static const mealTime = "meal_time";
  /// Days of the week the recipe is for
  static const weekday = "week_day";
  /// Personal rating
  static const rating = "rating";
  /// Frequency rating to indicate the recipe repetitiveness
  /// A higher frequency recipe will appear more than a lower
  static const frequency = "frequency";

  static List<String> get columns => [
    id,
    name,
    description,
    cookingTime,
    mealTime,
    weekday,
    rating,
    frequency,
  ];
}

class RecipeTable {
  static const tableName = "recipes";
  static const idType = "INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT NOT NULL";
  static const textType = "TEXT NOT NULL";
  static const intType = "INTEGER NOT NULL";
  static const dateTimeType = "INTEGER NOT NULL";

  static String onCreate(int version) {
    switch(version) {
      case 1: return """
        CREATE TABLE $tableName (
          ${RecipeFields.id} $idType,
          ${RecipeFields.name} $textType,
          ${RecipeFields.description} $textType,
          ${RecipeFields.mealTime} $intType,
          ${RecipeFields.weekday} $intType,
          ${RecipeFields.rating} $intType,
        ) ;
      """;
      default:
        assert(false, "Unimplemented create version: $version");
    }
    return "";
  }

  static String onUpgrade(int version) {
    switch(version) {
      default:
        assert(false, "Unimplemented upgrade version: $version");
    }
    return "";
  }
}