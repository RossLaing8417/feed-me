class RecipeFields {
  static const id = "id";
  static const name = "name";
  static const description = "description";
  static const mealTime = "meal_time";
  static const weekday = "week_day";
  static const rating = "rating";

  static List<String> get columns => [
    id,
    name,
    description,
    mealTime,
    weekday,
    rating,
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