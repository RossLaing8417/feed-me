import 'dart:async';

import 'package:feedme/core/weekday.dart';
import 'package:feedme/database/models/ingredient.dart';
import 'package:feedme/database/models/meal_plan.dart';
import 'package:feedme/database/models/measurement.dart';
import 'package:feedme/database/models/recipe.dart';
import 'package:feedme/database/models/recipe_ingredient.dart';
import 'package:feedme/database/schema/ingredient.dart';
import 'package:feedme/database/schema/meal_plan.dart';
import 'package:feedme/database/schema/measurement.dart';
import 'package:feedme/database/schema/recipe.dart';
import 'package:feedme/database/schema/recipe_ingredient.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final instance = AppDatabase._instance();
  static final name = "feed-me.db";
  static final version = 1;
  static Database? _db;

  static get dbPath async => join(await getDatabasesPath(), name);

  AppDatabase._instance();

  static Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    await initDatabase();
    return _db!;
  }

  static initDatabase() async {
    assert(_db == null, "Database already initialized");
    _db =
        _db ??
        await openDatabase(
          await dbPath,
          version: 1,
          onCreate: _createDatabase,
          onUpgrade: _upgradeDatabase,
        );
  }

  static Future _createDatabase(Database db, int version) async {
    await db.execute(IngredientTable.onCreate(version));
    await db.execute(MeasurementTable.onCreate(version));
    await db.execute(RecipeTable.onCreate(version));
    await db.execute(RecipeIngredientTable.onCreate(version));
    await db.execute(MealPlanTable.onCreate(version));
  }

  static Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    assert(
      newVersion > oldVersion,
      "New version must be greater than old version",
    );
    for (var version = oldVersion + 1; oldVersion <= newVersion; version += 1) {
      await db.execute(IngredientTable.onUpgrade(version));
      await db.execute(MeasurementTable.onUpgrade(version));
      await db.execute(RecipeTable.onUpgrade(version));
      await db.execute(RecipeIngredientTable.onUpgrade(version));
      await db.execute(MealPlanTable.onUpgrade(version));
    }
  }

  // >>> TEMP
  static reset() async {
    if (_db != null) {
      await _db!.close();
      await deleteDatabase(await dbPath);
      _db = null;
    }
    initDatabase();
  }

  // <<< TEMP

  // TODO: AND/OR grouping
  static Future<List<Map<String, Object?>>> _fetchRecords(
    String table, [
    QueryOpts? queryOpts,
  ]) async {
    final opts = queryOpts ?? QueryOpts();
    final filterQuery = <String>[];
    final filterValues = <Object>[];
    for (final filter in opts.filtering) {
      filterQuery.add("${filter.field} ${filter.operator} ?");
      switch (filter.value) {
        case DateTime v:
          filterValues.add(v.microsecondsSinceEpoch);
        default:
          filterValues.add(filter.value);
      }
    }
    final sortClause = opts.sorting.fold(
      "",
      (value, element) =>
          "${value.isEmpty ? "" : "$value, "}${element.field} ${element.ascending ? "ASC" : "DESC"}",
    );
    final where =
        filterQuery.isEmpty
            ? null
            : filterQuery.fold(
              "",
              (value, element) =>
                  "${value.isEmpty ? "" : "$value AND "} $element",
            );
    final whereArgs = filterValues.isEmpty ? null : filterValues;
    final orderBy = sortClause.isEmpty ? null : sortClause;
    return (await db).query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  static Future<Map<String, Object?>> _findRecord(
    String table,
    String fieldName,
    Object fieldValue,
  ) async {
    late bool valid;
    switch (fieldValue) {
      case int val:
        valid = val > 0;
      case String val:
        valid = val.isNotEmpty;
    }
    assert(
      valid,
      "Attempt to find a record with an invalid $fieldName: $fieldValue",
    );
    final results = await _fetchRecords(
      table,
      QueryOpts(filtering: [FilterField(field: fieldName, value: fieldValue)]),
    );
    assert(
      results.isNotEmpty,
      "Could not any '$table' with the id: $fieldValue",
    );
    assert(
      results.length == 1,
      "Found too many '$table' with the id: $fieldValue",
    );
    return Future.value(results[0]);
  }

  static Future<List<IngredientModel>> fetchIngredients([
    QueryOpts? queryOpts,
  ]) async {
    final records = await _fetchRecords(IngredientTable.name, queryOpts);
    return records.map((e) => IngredientModel.fromMap(e)).toList();
  }

  static Future<IngredientModel> getIngredientById(int id) async {
    return IngredientModel.fromMap(
      await _findRecord(IngredientTable.name, IngredientFields.id, id),
    );
  }

  static Future<IngredientModel> getIngredientByName(String name) async {
    return IngredientModel.fromMap(
      await _findRecord(IngredientTable.name, IngredientFields.name, name),
    );
  }

  static Future<IngredientModel> createIngredient({
    required String name,
    required int frequency,
  }) async {
    var model = IngredientModel(name: name, frequency: frequency);
    final id = await (await db).insert(IngredientTable.name, model.toMap());
    assert(id > 0, "Failed to create ingredient");
    return getIngredientById(id);
  }

  static Future<IngredientModel> updateIngredient({
    required int id,
    required String name,
    required int frequency,
  }) async {
    var model = await getIngredientById(id);
    model = IngredientModel(id: model.id, name: name, frequency: frequency);
    await (await db).update(
      IngredientTable.name,
      model.toMap(),
      where: "${IngredientFields.id} = ?",
      whereArgs: [id],
    );
    return getIngredientById(id);
  }

  static Future deleteIngredient(int id) async {
    final _ = await getIngredientById(id);
    await (await db).delete(
      IngredientTable.name,
      where: "${IngredientFields.id} = ?",
      whereArgs: [id],
    );
  }

  static Future<List<MeasurementModel>> fetchMeasurements([
    QueryOpts? queryOpts,
  ]) async {
    final records = await _fetchRecords(MeasurementTable.name, queryOpts);
    return records.map((e) => MeasurementModel.fromMap(e)).toList();
  }

  static Future<MeasurementModel> getMeasurementById(int id) async {
    return MeasurementModel.fromMap(
      await _findRecord(MeasurementTable.name, MeasurementFields.id, id),
    );
  }

  static Future<MeasurementModel> getMeasurementByLabel(String label) async {
    return MeasurementModel.fromMap(
      await _findRecord(MeasurementTable.name, MeasurementFields.label, label),
    );
  }

  static Future<MeasurementModel> createMeasurement({
    required String label,
    required String description,
  }) async {
    var model = MeasurementModel(label: label, description: description);
    final id = await (await db).insert(MeasurementTable.name, model.toMap());
    return getMeasurementById(id);
  }

  static Future<MeasurementModel> updateMeasurement({
    required int id,
    required String label,
    required String description,
  }) async {
    var model = await getMeasurementById(id);
    model = MeasurementModel(
      id: model.id,
      label: label,
      description: description,
    );
    await (await db).update(
      MeasurementTable.name,
      model.toMap(),
      where: "${MeasurementFields.id} = ?",
      whereArgs: [id],
    );
    return getMeasurementById(id);
  }

  static Future<void> deleteMeasurement(int id) async {
    final _ = getMeasurementById(id);
    await (await db).delete(
      MeasurementTable.name,
      where: "${MeasurementFields.id} = ?",
      whereArgs: [id],
    );
  }

  static Future<List<RecipeModel>> fetchRecipes([QueryOpts? queryOpts]) async {
    final records = await _fetchRecords(RecipeTable.name, queryOpts);
    return records.map((e) => RecipeModel.fromMap(e)).toList();
  }

  static Future<RecipeModel> getRecipeById(int id) async {
    return RecipeModel.fromMap(
      await _findRecord(RecipeTable.name, RecipeFields.id, id),
    );
  }

  static Future<RecipeModel> getRecipeByName(String name) async {
    return RecipeModel.fromMap(
      await _findRecord(RecipeTable.name, RecipeFields.name, name),
    );
  }

  static Future<RecipeModel> createRecipe({
    required String name,
    required String description,
    required String cookingTime,
    required Weekday weekday,
    required int rating,
    required int frequency,
  }) async {
    final model = RecipeModel(
      name: name,
      description: description,
      cookingTime: cookingTime,
      weekday: weekday,
      rating: rating,
      frequency: frequency,
    );
    final id = await (await db).insert(RecipeTable.name, model.toMap());
    return getRecipeById(id);
  }

  static Future<RecipeModel> updateRecipe({
    required int id,
    required String name,
    required String description,
    required String cookingTime,
    required Weekday weekday,
    required int rating,
    required int frequency,
  }) async {
    var model = await getRecipeById(id);
    model = RecipeModel(
      id: model.id,
      name: name,
      description: description,
      cookingTime: cookingTime,
      weekday: weekday,
      rating: rating,
      frequency: frequency,
    );
    await (await db).update(
      RecipeTable.name,
      model.toMap(),
      where: "${RecipeFields.id} = ?",
      whereArgs: [id],
    );
    return getRecipeById(id);
  }

  static Future<void> deleteRecipes(int id) async {
    final _ = await getRecipeById(id);
    await (await db).delete(
      RecipeTable.name,
      where: "${RecipeFields.id} = ?",
      whereArgs: [id],
    );
  }

  static Future<List<RecipeIngredientModel>> fetchRecipeIngredients([
    QueryOpts? queryOpts,
  ]) async {
    final records = await _fetchRecords(RecipeIngredientTable.name, queryOpts);
    return records.map((e) => RecipeIngredientModel.fromMap(e)).toList();
  }

  static Future<RecipeIngredientModel> getRecipeIngredientById(int id) async {
    return RecipeIngredientModel.fromMap(
      await _findRecord(
        RecipeIngredientTable.name,
        RecipeIngredientFields.id,
        id,
      ),
    );
  }

  static Future<RecipeIngredientModel> createRecipeIngredient({
    required int recipeId,
    required int ingredientId,
    required String label,
    required String description,
    required int measurementId,
    required double measurementValue,
  }) async {
    final model = RecipeIngredientModel(
      recipeId: recipeId,
      ingredientId: ingredientId,
      label: label,
      description: description,
      measurementId: measurementId,
      measurementValue: measurementValue,
    );
    final id = await (await db).insert(
      RecipeIngredientTable.name,
      model.toMap(),
    );
    return getRecipeIngredientById(id);
  }

  static Future<RecipeIngredientModel> updateRecipeIngredient({
    required int id,
    required String label,
    required String description,
    required double measurementValue,
  }) async {
    var model = await getRecipeIngredientById(id);
    model = RecipeIngredientModel(
      id: model.id,
      recipeId: model.recipeId,
      ingredientId: model.ingredientId,
      measurementId: model.measurementId,
      label: label,
      description: description,
      measurementValue: measurementValue,
    );
    await (await db).update(
      RecipeIngredientTable.name,
      model.toMap(),
      where: "${RecipeIngredientFields.id} = ?",
      whereArgs: [id],
    );
    return getRecipeIngredientById(id);
  }

  static Future<void> deleteRecipeIngredients({required int id}) async {
    final _ = await getRecipeIngredientById(id);
    await (await db).delete(
      RecipeIngredientTable.name,
      where: "${RecipeIngredientFields.id} = ?",
      whereArgs: [id],
    );
  }

  static Future<List<MealPlanModel>> fetchMealPlans([
    QueryOpts? queryOpts,
  ]) async {
    final records = await _fetchRecords(MealPlanTable.name, queryOpts);
    return records.map((e) => MealPlanModel.fromMap(e)).toList();
  }

  static Future<MealPlanModel> getMealPlanById(int id) async {
    return MealPlanModel.fromMap(
      await _findRecord(MealPlanTable.name, MealPlanFields.id, id),
    );
  }

  /// From [startDate] (inclusive) to [endDate] (exclusive)
  static Future<List<MealPlanModel>> getMealPlansForRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return fetchMealPlans(
      QueryOpts(
        filtering: [
          FilterField(
            field: MealPlanFields.mealDate,
            operator: FilterField.ge,
            value: startDate,
          ),
          FilterField(
            field: MealPlanFields.mealDate,
            operator: FilterField.le,
            value: endDate,
          ),
        ],
        sorting: [SortField(field: MealPlanFields.mealDate)],
      ),
    );
  }

  static Future<MealPlanModel> createMealPlan({
    required int recipeId,
    required DateTime mealDate,
    required String notes,
  }) async {
    final model = MealPlanModel(
      recipeId: recipeId,
      mealDate: mealDate,
      notes: notes,
    );
    final id = await (await db).insert(MealPlanTable.name, model.toMap());
    return getMealPlanById(id);
  }

  static Future<MealPlanModel> updateMealPlan({
    required int id,
    required int recipeId,
    required DateTime mealDate,
    required String notes,
  }) async {
    var model = await getMealPlanById(id);
    model = MealPlanModel(
      id: model.id,
      recipeId: recipeId,
      mealDate: mealDate,
      notes: notes,
    );
    await (await db).update(
      MealPlanTable.name,
      model.toMap(),
      where: "${MealPlanFields.id} = ?",
      whereArgs: [id],
    );
    return getMealPlanById(id);
  }

  static Future<void> deleteMealPlans({required int id}) async {
    final _ = await getMealPlanById(id);
    await (await db).delete(
      MealPlanTable.name,
      where: "${MealPlanFields.id} = ?",
      whereArgs: [id],
    );
  }
}

class QueryOpts {
  final List<FilterField> filtering;
  final List<SortField> sorting;

  QueryOpts({List<FilterField>? filtering, List<SortField>? sorting})
    : filtering = filtering ?? [],
      sorting = sorting ?? [];
}

class FilterField {
  final String field;
  final String operator;
  final Object value;

  FilterField({required this.field, this.operator = "==", required this.value});

  /// Equal
  static final eq = "==";

  /// Not equal
  static final ne = "!=";

  /// Greater than
  static final gt = ">";

  /// Less than
  static final lt = "<";

  /// Greater than or equal
  static final ge = ">=";

  /// Less than or equal
  static final le = "<=";

  /// SQL Like (i.e matches)
  static final like = "LIKE";
}

class SortField {
  final String field;
  final bool ascending;

  SortField({required this.field, this.ascending = true});
}
