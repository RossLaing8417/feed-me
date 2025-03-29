import 'package:feedme/core/mealtime.dart';
import 'package:feedme/core/weekday.dart';
import 'package:feedme/database/database.dart';
import 'package:feedme/database/models/recipe.dart';
import 'package:feedme/views/widgets/weekday_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  refresh() {
    final model = AppDatabase.recipes.firstWhere((element) => element.id == widget.id);
    setState(() {
      _recipe = model;
    });
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
          SizedBox(height: 32.0),
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
                  onPressed: () {},
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
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: 100,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text("Noice"),
                      titleTextStyle: Theme.of(context).textTheme.titleMedium,
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