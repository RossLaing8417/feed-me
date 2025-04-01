class IngredientFields {
  /// Unique identifier
  static const id = "id";

  /// Ingredient name
  static const name = "name";

  /// Frequency rating to indicate the ingredients repetitiveness
  /// A higher frequency ingredient will appear more often than a lower
  static const frequency = "frequency";

  static const columns = [id, name, frequency];
}

class IngredientTable {
  static const name = "ingredients";
  static const idType = "INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT NOT NULL";
  static const textType = "TEXT NOT NULL";
  static const intType = "INTEGER NOT NULL";

  static String onCreate(int version) {
    switch (version) {
      case 1:
        return """
        CREATE TABLE $name (
          ${IngredientFields.id} $idType
        , ${IngredientFields.name} $textType
        , ${IngredientFields.frequency} $intType
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
