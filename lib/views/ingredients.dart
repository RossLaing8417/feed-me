import 'dart:async';

import 'package:feedme/database/database.dart';
import 'package:feedme/database/models/ingredient.dart';
import 'package:feedme/views/widgets/numeric_step_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppIngredientsView extends StatefulWidget {
  const AppIngredientsView({super.key});

  @override
  State<AppIngredientsView> createState() => _AppIngredientsViewState();
}

class _AppIngredientsViewState extends State<AppIngredientsView> {
  List<IngredientModel> _ingredients = [];
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  applyFilter(String filter) {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce?.cancel();
    }
    _searchDebounce = Timer(Duration(milliseconds: 200), () {
      setState(() {
        _ingredients = AppDatabase.ingredients.where((element)
          => element.name.toLowerCase().contains(filter)).toList();
        _ingredients.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        // AppDatabase.fetchIngredients(QueryOpts(
        //   filtering:  [
        //     FilterField(
        //         field: IngredientFields.name,
        //         operator: FilterField.like,
        //         value: "%${filter.replaceAll(" ", "%")}%",
        //     )
        //   ],
        //   sorting: [SortField(field: IngredientFields.name)],
        // ));
      });
    });
  }

  search() {
    setState(() {
      applyFilter(_searchController.text.toLowerCase());
    });
  }

  editIngredient([int? id]) async {
    await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AppIngredientEditView(id: id))
    );
    search();
  }

  deleteIngredient(int id) {
    AppDatabase.deleteIngredient(id: id).then((_) => search());
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(search);
    search();
  }

  @override
  void dispose() {
    _searchController.removeListener(search);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          spacing: 16.0,
          children: [
            SearchBar(
              controller: _searchController,
              leading: Icon(CupertinoIcons.search),
              hintText: "Search...",
              trailing: [
                if (_searchController.text != "")
                  IconButton(
                    onPressed: () => setState(() => _searchController.clear()),
                    icon: Icon(CupertinoIcons.xmark),
                  ),
              ],
            ),
            Expanded(
              child: Center(
                child: _ingredients.isEmpty
                ? Text("No ingredients found...")
                : ListView.builder(
                  itemCount: _ingredients.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => editIngredient(_ingredients[index].id!),
                    onLongPress: () => openDeleteDialog(_ingredients[index].id!),
                    child: Expanded(child: Card(
                      child: ListTile(
                        title: Text(_ingredients[index].name),
                        titleTextStyle: Theme.of(context).textTheme.titleLarge,
                        subtitle: Text(_ingredients[index].frequency.toString()),
                        subtitleTextStyle: Theme.of(context).textTheme.titleSmall,
                      ),
                    )),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => editIngredient(),
        tooltip: "Add ingredient",
        child: Icon(CupertinoIcons.add),
      )
    );
  }

  Future openDeleteDialog(int id) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure you want to delete this ingredient?"),
        actions: [
          FilledButton(
            onPressed: () {
              deleteIngredient(id);
              Navigator.of(context).pop();
            },
            child: Text("Delete"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }
}

class AppIngredientEditView extends StatefulWidget {
  final int? id;
  const AppIngredientEditView({super.key, this.id});

  @override
  State<AppIngredientEditView> createState() => _AppIngredientEditViewState();
}

class _AppIngredientEditViewState extends State<AppIngredientEditView> {
  var _isNew = false;
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  int _frequency = 0;

  refresh() {
    if (widget.id == null) {
      setState(() {
        _isNew = true;
      });
      return;
    }
    final model = AppDatabase.ingredients.firstWhere((element) => element.id == widget.id);
    setState(() {
      _isNew = false;
      _name = model.name;
      _frequency = model.frequency;
    });
  }

  saveChanges(context) async {
    final _ = _isNew
      ? await AppDatabase.createIngredient(
        name: _name,
        frequency: _frequency,
      )
      : await AppDatabase.updateIngredient(
        id: widget.id!,
        name: _name,
        frequency: _frequency,
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
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 100,
                decoration: InputDecoration(label: Text("Name")),
                initialValue: _name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please provide a name";
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              NumericStepButtonFormField(
                minValue: 0,
                maxValue: 10,
                label: "Frequency",
                initialValue: _frequency,
                validator: (value) {
                  if (value == null || value == 0) {
                    return "Please provide a frequency";
                  }
                  return null;
                },
                onSaved: (value) => _frequency = value!,
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
        tooltip: "Save",
        child: Icon(CupertinoIcons.checkmark_alt),
      ),
    );
  }
}
