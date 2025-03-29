class MeasurementFields {
  static const id = "id";
  static const label = "label";
  static const description = "description";
}

class MeasurementTable {
  static const tableName = "measurements";
  static const idType = "INTEGER UNIQUE PRIMARY KEY NOT NULL";
  static const textType = "TEXT NOT NULL";

  static String onCreate(int version) {
    switch (version) {
      case 1: return """
        CREATE TABLE $tableName (
          ${MeasurementFields.id} $idType,
          ${MeasurementFields.label} $textType,
          ${MeasurementFields.description} $textType
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