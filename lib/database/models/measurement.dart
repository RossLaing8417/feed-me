import 'package:feedme/database/schema/measurement.dart';

class MeasurementModel {
  final int? id;
  final String label;
  final String description;

  MeasurementModel({
    this.id,
    required this.label,
    required this.description,
  });

  factory MeasurementModel.fromMap(Map<String, Object?> map) => MeasurementModel(
    id: map[MeasurementFields.id] as int?,
    label: map[MeasurementFields.label] as String,
    description: map[MeasurementFields.description] as String,
  );

  Map<String, Object?> toMap() {
    return {
      // MeasurementFields.id: id,
      MeasurementFields.label: label,
      MeasurementFields.description: description,
    };
  }
}