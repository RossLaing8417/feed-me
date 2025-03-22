import 'package:feedme/database/schema/ingredient.dart';

class IngredientModel {
  final int? id;
  final String name;
  final int frequency;

  const IngredientModel({
    this.id,
    required this.name,
    required this.frequency,
  });

  Map<String, Object?> toMap() {
    return {
      // IngredientFields.id: id,
      IngredientFields.name: name,
      IngredientFields.frequency: frequency,
    };
  }
}