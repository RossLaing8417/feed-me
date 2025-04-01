class MeasurementFields {
  /// Unique identifier
  static const id = "id";

  /// Measurement label (e.g kg, tsp, ml)
  static const label = "label";

  /// Measurement description (e.g kilogram, teaspoon, milli-litre)
  static const description = "description";

  static const columns = [id, label, description];
}

class MeasurementTable {
  static const name = "measurements";
  static const idType = "INTEGER UNIQUE PRIMARY KEY NOT NULL";
  static const textType = "TEXT NOT NULL";

  static String onCreate(int version) {
    switch (version) {
      case 1:
        return """
        CREATE TABLE $name (
          ${MeasurementFields.id} $idType
        , ${MeasurementFields.label} $textType
        , ${MeasurementFields.description} $textType
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
