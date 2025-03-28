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

  factory IngredientModel.fromMap(Map<String, Object?> map)
    => IngredientModel(
      id: map[IngredientFields.id] as int?,
      name: map[IngredientFields.name] as String,
      frequency: map[IngredientFields.frequency] as int,
    );

  Map<String, Object?> toMap() {
    return {
      // IngredientFields.id: id,
      IngredientFields.name: name,
      IngredientFields.frequency: frequency,
    };
  }
}