import 'dart:async';

import 'package:feedme/core/mealtime.dart';
import 'package:feedme/core/weekday.dart';
import 'package:feedme/database/models/ingredient.dart';
import 'package:feedme/database/models/recipe.dart';
import 'package:feedme/database/schema/ingredient.dart';
import 'package:feedme/database/schema/measurement.dart';
import 'package:feedme/database/schema/recipe.dart';
import 'package:feedme/database/schema/recipe_ingredient.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final instance = AppDatabase._instance();
  static final name = "feedme.db";
  static Database? _db;

  AppDatabase._instance();

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await _initDatabase();
    return _db!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), name);
    // await deleteDatabase(path);
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  static Future<void> _createDatabase(Database db, int version) async {
    return db.execute("""
      ${RecipeTable.onCreate(version)}
      ${IngredientTable.onCreate(version)}
      ${MeasurementTable.onCreate(version)}
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
        ${RecipeTable.onUpgrade(version)}
        ${IngredientTable.onUpgrade(version)}
        ${MeasurementTable.onUpgrade(version)}
        ${RecipeIngredientTable.onUpgrade(version)}
      """);
    }
  }

  // >>> TEMP
  static printSql(int version) {
    final data = """
      ${RecipeTable.onCreate(version)}
      ${IngredientTable.onCreate(version)}
      ${MeasurementTable.onCreate(version)}
      ${RecipeIngredientTable.onCreate(version)}
    """;
    print(data);
  }

  static List<RecipeModel> recipes = [];
  static List<IngredientModel> ingredients = [];

  static int _id = 0;
  static int get _nextId {
    _id += 1;
    return _id;
  }
  // <<< TEMP

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
      createdDateTime: DateTime.now(),
      lastModifiedDateTime: DateTime.now(),
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
      createdDateTime: model.createdDateTime,
      lastModifiedDateTime: DateTime.now(),
    );
    recipes.add(model);
    return recipes.firstWhere((element) => element.id == model.id);
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
}