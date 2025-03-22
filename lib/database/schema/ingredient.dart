class IngredientFields {
  static const id = "id";
  static const name = "name";
  static const frequency = "frequency";
}

class IngredientTable {
  static const tableName = "ingredients";
  static const idType = "INTEGER UNIQUE PRIMARY KEY AUTOINCREMENT NOT NULL";
  static const textType = "TEXT NOT NULL";
  static const intType = "INTEGER NOT NULL";

  static String onCreate(int version) {
    switch (version) {
      case 1: return """
        CREATE TABLE $tableName (
          ${IngredientFields.id} $idType,
          ${IngredientFields.name} $textType,
          ${IngredientFields.frequency} $intType,
        ) STRICT;
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