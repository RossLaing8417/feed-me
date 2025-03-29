import 'dart:async';

import 'package:feedme/core/mealtime.dart';
import 'package:feedme/core/weekday.dart';
import 'package:feedme/database/models/ingredient.dart';
import 'package:feedme/database/models/measurement.dart';
import 'package:feedme/database/models/recipe.dart';
import 'package:feedme/database/models/recipe_ingredient.dart';
import 'package:feedme/database/schema/ingredient.dart';
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

  AppDatabase._instance();

  static Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDatabase();
    return _db!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), name);
    print("DB PATH: $path");
    try {
      await deleteDatabase(path);
    } catch (e) {
      print("Failed to delete db: $e");
    }
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  static Future<void> _createDatabase(Database db, int version) async {
    return db.execute("""
      ${IngredientTable.onCreate(version)}
      ${MeasurementTable.onCreate(version)}
      ${RecipeTable.onCreate(version)}
      ${RecipeIngredientTable.onCreate(version)}
    """);
  }

  static Future<void> _upgradeDatabase(
      Database db,
      int oldVersion,
      int newVersion,
  ) async {
    assert(newVersion > oldVersion, "New version must be greater than old version");
    for (var version = oldVersion + 1; oldVersion <= newVersion; version += 1) {
      await db.execute("""
        ${IngredientTable.onUpgrade(version)}
        ${MeasurementTable.onUpgrade(version)}
        ${RecipeTable.onUpgrade(version)}
        ${RecipeIngredientTable.onUpgrade(version)}
      """);
    }
  }

  // >>> TEMP
  static printSql() {
    final data = """
      ${IngredientTable.onCreate(version)}
      ${MeasurementTable.onCreate(version)}
      ${RecipeTable.onCreate(version)}
      ${RecipeIngredientTable.onCreate(version)}
    """;
    print(data);
  }

  static List<IngredientModel> ingredients = [];
  static List<MeasurementModel> measurements = [];
  static List<RecipeModel> recipes = [];
  static List<RecipeIngredientModel> recipeIngredients = [];

  static int _id = 0;
  static int get _nextId {
    _id += 1;
    return _id;
  }
  // <<< TEMP

  // TODO: AND/OR grouping
  static Future<List<Map<String, Object?>>> _fetchRecords(
    String tableName,
    [QueryOpts? queryOpts]
  ) async {
    final opts = queryOpts ?? QueryOpts();
    final filterQuery = <String>[];
    final filterValues = <Object>[];
    for (final filter in opts.filtering) {
      filterQuery.add("${filter.field} ${filter.operator} ?");
      filterValues.add(filter.value);
    }
    final sortClause = opts.sorting.fold("", (value, element)
      => "$value, ${element.field} ${element.ascending ? "ASC" : "DESC"}");
    return (await db).query(
      tableName,
      where: filterQuery.fold("", (value, element) => "$value AND $element"),
      whereArgs: filterValues,
      orderBy: sortClause,
    );
  }

  static Future<List<IngredientModel>> fetchIngredients(
      [QueryOpts? queryOpts]
      ) async {
    final records = await _fetchRecords(IngredientTable.tableName, queryOpts);
    return records.map((e) => IngredientModel.fromMap(e)).toList();
  }

  static Future<IngredientModel> createIngredient({
    required String name,
    required int frequency,
  }) async {
    var model = IngredientModel(
      id: _nextId,
      name: name,
      frequency: frequency,
    );
    ingredients.add(model);
    return ingredients.firstWhere((element) => element.id == model.id);
  }

  static Future<IngredientModel> updateIngredient({
    required int id,
    required String name,
    required int frequency,
  }) async {
    var model = ingredients.firstWhere((element) => element.id == id);
    ingredients.remove(model);
    model = IngredientModel(
      id: model.id,
      name: name,
      frequency: frequency,
    );
    ingredients.add(model);
    return ingredients.firstWhere((element) => element.id == model.id);
  }

  static Future<void> deleteIngredient({required int id}) async {
    final model = ingredients.firstWhere((element) => element.id == id);
    ingredients.remove(model);
    return Future.value();
  }

  static Future<List<MeasurementModel>> fetchMeasurements(
    [QueryOpts? queryOpts]
  ) async {
    final records = await _fetchRecords(MeasurementTable.tableName, queryOpts);
    return records.map((e) => MeasurementModel.fromMap(e)).toList();
  }

  static Future<MeasurementModel> createMeasurement({
    required String label,
    required String description,
  }) async {
    var model = MeasurementModel(
      id: _nextId,
      label: label,
      description: description,
    );
    measurements.add(model);
    return measurements.firstWhere((element) => element.id == model.id);
  }

  static Future<MeasurementModel> updateMeasurement({
    required int id,
    required String label,
    required String description,
  }) async {
    var model = measurements.firstWhere((element) => element.id == id);
    measurements.remove(model);
    model = MeasurementModel(
      id: model.id,
      label: label,
      description: description,
    );
    measurements.add(model);
    return measurements.firstWhere((element) => element.id == model.id);
  }

  static Future<void> deleteMeasurement({required int id}) async {
    final model = measurements.firstWhere((element) => element.id == id);
    measurements.remove(model);
    return Future.value();
  }

  static Future<List<RecipeModel>> fetchRecipes(
    [QueryOpts? queryOpts]
  ) async {
    final records = await _fetchRecords(RecipeTable.tableName, queryOpts);
    return records.map((e) => RecipeModel.fromMap(e)).toList();
  }

  static Future<RecipeModel> createRecipe({
    required String name,
    required String description,
    required MealTime mealTime,
    required Weekday weekday,
    required int rating,
  }) async {
    final model = RecipeModel(
      id: _nextId,
      name: name,
      description: description,
      mealTime: mealTime,
      weekday: weekday,
      rating: rating,
    );
    recipes.add(model);
    return recipes.firstWhere((element) => element.id == model.id);
  }

  static Future<RecipeModel> updateRecipe({
    required int id,
    required String name,
    required String description,
    required MealTime mealTime,
    required Weekday weekday,
    required int rating,
  }) async {
    var model = recipes.firstWhere((element) => element.id == id);
    recipes.remove(model);
    model = RecipeModel(
      id: model.id,
      name: name,
      description: description,
      mealTime: mealTime,
      weekday: weekday,
      rating: rating,
    );
    recipes.add(model);
    return recipes.firstWhere((element) => element.id == model.id);
  }

  static Future<void> deleteRecipes({required int id}) async {
    final model = recipes.firstWhere((element) => element.id == id);
    recipes.remove(model);
    return Future.value();
  }

  static Future<List<RecipeIngredientModel>> fetchRecipeIngredients(
      [QueryOpts? queryOpts]
      ) async {
    final records = await _fetchRecords(RecipeIngredientTable.tableName, queryOpts);
    return records.map((e) => RecipeIngredientModel.fromMap(e)).toList();
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
      id: _nextId,
      recipeId: recipeId,
      ingredientId: ingredientId,
      label: label,
      description: description,
      measurementId: measurementId,
      measurementValue: measurementValue,
    );
    recipeIngredients.add(model);
    return recipeIngredients.firstWhere((element) => element.id == model.id);
  }

  static Future<RecipeIngredientModel> updateRecipeIngredient({
    required int id,
    required String label,
    required String description,
    required double measurementValue,
  }) async {
    var model = recipeIngredients.firstWhere((element) => element.id == id);
    recipeIngredients.remove(model);
    model = RecipeIngredientModel(
      id: model.id,
      recipeId: model.recipeId,
      ingredientId: model.ingredientId,
      measurementId: model.measurementId,
      label: label,
      description: description,
      measurementValue: measurementValue,
    );
    recipeIngredients.add(model);
    return recipeIngredients.firstWhere((element) => element.id == model.id);
  }

  static Future<void> deleteRecipeIngredients({required int id}) async {
    final model = recipeIngredients.firstWhere((element) => element.id == id);
    recipeIngredients.remove(model);
    return Future.value();
  }
}

class QueryOpts {
  final List<FilterField> filtering;
  final List<SortField> sorting;
  QueryOpts({List<FilterField>? filtering, List<SortField>? sorting})
    : filtering = filtering ?? [], sorting = sorting ?? [];
}

class FilterField {
  final String field;
  final String operator;
  final Object value;
  FilterField({required this.field, this.operator = "==", required this.value});

  static final eq = "==";
  static final ne = "!=";
  static final gt = ">";
  static final lt = "<";
  static final ge = ">=";
  static final le = "<=";
  static final like = "LIKE";
}

class SortField {
  final String field;
  final bool ascending;
  SortField({required this.field, this.ascending = true});
}