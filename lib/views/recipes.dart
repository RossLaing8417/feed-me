import 'package:dropdown_search/dropdown_search.dart';
import 'package:feedme/core/mealtime.dart';
import 'package:feedme/core/weekday.dart';
import 'package:feedme/database/database.dart';
import 'package:feedme/database/models/ingredient.dart';
import 'package:feedme/database/models/measurement.dart';
import 'package:feedme/database/models/recipe.dart';
import 'package:feedme/database/models/recipe_ingredient.dart';
import 'package:feedme/views/ingredients.dart';
import 'package:feedme/views/measurements.dart';
import 'package:feedme/views/widgets/weekday_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating/flutter_rating.dart';

class AppRecipesView extends StatefulWidget {
  const AppRecipesView({super.key});

  @override
  State<AppRecipesView> createState() => _AppRecipesViewState();
}

class _AppRecipesViewState extends State<AppRecipesView> {
  List<RecipeModel> _recipes = [];
  final _searchController = TextEditingController();

  filterRecipes() {
    final search = _searchController.text;
    setState(() {
      _recipes = AppDatabase.recipes.where((element)
        => element.name.contains(search)).toList();
      _recipes.sort((a,b)
        => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  addRecipe() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AppRecipeEditView()),
    );
    filterRecipes();
  }

  viewRecipe(context, int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AppRecipeView(id)),
    );
    filterRecipes();
  }

  @override
  void initState() {
    super.initState();
    filterRecipes();
    _searchController.addListener(filterRecipes);
  }

  @override
  void dispose() {
    _searchController.removeListener(filterRecipes);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _recipes.isEmpty
            ? const Text("No recipes found...")
            : ListView.builder(
          itemCount: _recipes.length,
          itemBuilder: (context, index) {
            final recipe = _recipes[index];
            return Card(
              child: ListTile(
                onTap: () => viewRecipe(context, recipe.id!),
                title: Text(recipe.name),
                titleTextStyle: Theme.of(context).textTheme.headlineMedium,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addRecipe,
        tooltip: "Add Recipe",
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}

class AppRecipeView extends StatefulWidget {
  final int id;

  const AppRecipeView(this.id, {super.key});

  @override
  State<AppRecipeView> createState() => _AppRecipeViewState();
}

class _AppRecipeViewState extends State<AppRecipeView> {
  late RecipeModel _recipe;
  List<RecipeIngredientModel> _ingredients = [];

  refresh() {
    final model = AppDatabase.recipes.firstWhere((element)
      => element.id == widget.id);
    final ingredients = AppDatabase.recipeIngredients.where((element)
      => element.recipeId == widget.id).toList();
    setState(() {
      _recipe = model;
      _ingredients = ingredients;
      _ingredients.sort((a, b) =>
          a.label.toString().compareTo(b.label.toLowerCase()));
    });
  }

  editIngredient([int? id]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppRecipeIngredientEditView(id: id, recipeId: widget.id),
      ),
    );
    refresh();
  }

  deleteIngredient(int id) async {
    await AppDatabase.deleteRecipeIngredients(id: id);
    refresh();
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _recipe.name,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          Text(
            _recipe.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            _recipe.weekday.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          StarRating(
            rating: _recipe.rating.toDouble(),
          ),
          Divider(height: 32.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ingredients",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                FilledButton(
                  onPressed: editIngredient,
                  child: Icon(CupertinoIcons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              // child: Placeholder(),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  final measurement = AppDatabase.measurements.firstWhere((element)
                    => element.id == ingredient.measurementId);
                  return Card(
                    child: ListTile(
                      onTap: () => editIngredient(ingredient.id!),
                      onLongPress: () => openDeleteDialog(ingredient.id!),
                      title: Text(ingredient.label),
                      titleTextStyle: Theme.of(context).textTheme.titleMedium,
                      subtitle: Text("${ingredient.measurementValue} ${measurement.label}"),
                      subtitleTextStyle: Theme.of(context).textTheme.titleSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 64.0 + 16.0),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AppRecipeEditView(id: _recipe.id)),
        ).then((value) => refresh()),
        tooltip: "Edit",
        child: const Icon(CupertinoIcons.pencil),
      ),
    );
  }

  Future openDeleteDialog(int id) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure you want to remove this ingredient"),
        actions: [
          FilledButton(
            onPressed: () {
              deleteIngredient(id);
              Navigator.of(context).pop();
            },
            child: Text("Delete"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }
}

class AppRecipeEditView extends StatefulWidget {
  final int? id;

  const AppRecipeEditView({super.key, this.id});

  @override
  State<AppRecipeEditView> createState() => _AppRecipeEditViewState();
}

class _AppRecipeEditViewState extends State<AppRecipeEditView> {
  bool _isNew = false;
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _description = "";
  Weekday _weekday = Weekday.none;
  int _rating = 0;

  refresh() {
    if (widget.id == null) {
      setState(() {
        _isNew = true;
      });
      return;
    }
    final model = AppDatabase.recipes.firstWhere((element) => element.id == widget.id!);
    setState(() {
      _isNew = false;
      _name = model.name;
      _description = model.description;
      _weekday = model.weekday;
      _rating = model.rating;
    });
  }

  saveChanges(context) async {
    final RecipeModel model = _isNew
      ? await AppDatabase.createRecipe(
        name: _name,
        description: _description,
        mealTime: MealTime.supper,
        weekday: _weekday,
        rating: _rating,
      )
      : await AppDatabase.updateRecipe(
        id: widget.id!,
        name: _name,
        description: _description,
        mealTime: MealTime.supper,
        weekday: _weekday,
        rating: _rating,
      );
    if (_isNew) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (builder) => AppRecipeView(model.id!))
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                maxLength: 100,
                decoration: InputDecoration(labelText: "Name"),
                initialValue: _name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please provide a name";
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                maxLength: 300,
                maxLines: 3,
                decoration: InputDecoration(labelText: "Description"),
                initialValue: _description,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please provide a description";
                  }
                  return null;
                },
                onSaved: (value) => _description = value!,
              ),
              WeekdaySelector(
                decoration: InputDecoration(labelText: "Weekday"),
                initialValue: _weekday,
                validator: (value) {
                  if (value == null || value.hasNone()) {
                    return "Please select a weekday";
                  }
                  return null;
                },
                onSaved: (value) => _weekday = value!,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InputDecorator(
                    decoration: InputDecoration(labelText: "Rating"),
                    child: StarRating(
                      mainAxisAlignment: MainAxisAlignment.start,
                      size: 40.0,
                      rating: _rating.toDouble(),
                      allowHalfRating: false,
                      onRatingChanged: (value) => setState(() => _rating = value.toInt()),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            saveChanges(context);
          }
        },
        tooltip: "Save",
        child: const Icon(CupertinoIcons.checkmark_alt),
      ),
    );
  }
}

class AppRecipeIngredientEditView extends StatefulWidget {
  final int? id;
  final int? recipeId;

  const AppRecipeIngredientEditView({
    super.key,
    this.recipeId,
    this.id,
  }) : assert(
    id != null || id == null && recipeId != null,
    "Either an id or recipe id must be provided"
  );

  @override
  State<AppRecipeIngredientEditView> createState() => _AppRecipeIngredientEditViewState();
}

class _AppRecipeIngredientEditViewState extends State<AppRecipeIngredientEditView> {
  var _isNew = false;
  final _formKey = GlobalKey<FormState>();

  IngredientModel? _ingredient;
  String _label = "";
  String _description = "";
  MeasurementModel? _measurement;
  String _measurementValue = "";

  refresh() {
    if (widget.id == null) {
      setState(() {
        _isNew = true;
      });
      return;
    }
    final model = AppDatabase.recipeIngredients.firstWhere((element) => element.id == widget.id);
    setState(() {
      _ingredient = AppDatabase.ingredients.firstWhere((element) => element.id == model.ingredientId);
      _label = model.label;
      _description = model.description;
      _measurement = AppDatabase.measurements.firstWhere((element) => element.id == model.measurementId);
      _measurementValue = model.measurementValue.toString();
    });
  }

  saveChanges(context) async {
    final _ = _isNew
      ? await AppDatabase.createRecipeIngredient(
        recipeId: widget.recipeId!,
        ingredientId: _ingredient!.id!,
        label: _label,
        description: _description,
        measurementId: _measurement!.id!,
        measurementValue: double.parse(_measurementValue)
      )
      : await AppDatabase.updateRecipeIngredient(
        id: widget.id!,
        label: _label,
        description: _description,
        measurementValue: double.parse(_measurementValue)
      );
    Navigator.pop(context);
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              switch(value) {
                case 0: Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AppIngredientsView())
                );
                case 1: Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AppMeasurementsView())
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Text("Ingredients"),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text("Measurements"),
              ),
            ],
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: _isNew
                  // TODO: Search
                  ? DropdownSearch<IngredientModel>(
                    items: (filter, loadProps) => AppDatabase.ingredients,
                    selectedItem: _ingredient,
                    compareFn: (item1, item2) => item1.id! == item2.id!,
                    itemAsString: (item) => item.name,
                    filterFn: (item, filter)
                      => item.name.toLowerCase().contains(filter.toLowerCase()),
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(labelText: "Ingredient")
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "Please select an ingredient";
                      }
                      return null;
                    },
                    onSaved: (newValue) => _ingredient = newValue,
                  )
                  : Text(_ingredient!.name),
                )
              ]),
              TextFormField(
                maxLength: 100,
                decoration: InputDecoration(labelText: "Label"),
                initialValue: _label,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please provide a label";
                  }
                  return null;
                },
                onSaved: (newValue) => _label = newValue!,
              ),
              TextFormField(
                maxLength: 250,
                maxLines: 3,
                decoration: InputDecoration(labelText: "Description"),
                initialValue: _description,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please provide a description";
                  }
                  return null;
                },
                onSaved: (newValue) => _description = newValue!,
              ),
              Row(children: [
                Expanded(
                  child: _isNew
                  // TODO: Search
                  ? DropdownSearch<MeasurementModel>(
                    items: (filter, loadProps) => AppDatabase.measurements,
                    selectedItem: _measurement,
                    compareFn: (item1, item2) => item1.id! == item2.id!,
                    itemAsString: (item) => item.label,
                    filterFn: (item, filter) => item.label.contains(filter),
                    decoratorProps: DropDownDecoratorProps(
                        decoration: InputDecoration(labelText: "Measurement")
                    ),
                    validator: (value) {
                      if (value == null) {
                        return "Please select a measurement";
                      }
                      return null;
                    },
                    onSaved: (newValue) => _measurement = newValue,
                  )
                  : Text(_measurement!.label),
                )
              ]),
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(
                  signed: false,
                  decimal: true
                ),
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.isNotEmpty && double.tryParse(newValue.text) == null) {
                      return oldValue;
                    }
                    return newValue;
                  }),
                ],
                decoration: InputDecoration(labelText: "Value"),
                initialValue: _measurementValue.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please provide a value";
                  }
                  return null;
                },
                onSaved: (newValue) => _measurementValue = newValue!,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();
            saveChanges(context);
          }
        },
        child: Icon(CupertinoIcons.checkmark_alt),
      ),
    );
  }
}
