import 'dart:async';

import 'package:feedme/database/database.dart';
import 'package:feedme/database/models/ingredient.dart';
import 'package:feedme/views/widgets/numeric_step_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IngredientsView extends StatefulWidget {
  const IngredientsView({super.key});

  @override
  State<IngredientsView> createState() => _IngredientsViewState();
}

class _IngredientsViewState extends State<IngredientsView> {
  List<IngredientModel> _ingredients = [];
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  final _formKey = GlobalKey<FormState>();

  int? _id = 0;
  String _name = "";
  int _frequency = 0;

  applyFilter(String filter) {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce?.cancel();
    }
    _searchDebounce = Timer(Duration(milliseconds: 200), () {
      setState(() {
        _ingredients = AppDatabase.ingredients.where((element)
          => element.name.toLowerCase().contains(filter)).toList();
      });
    });
  }

  search() {
    setState(() {
      applyFilter(_searchController.text.toLowerCase());
    });
  }

  saveIngredient() {
    var future = _id == null
      ? AppDatabase.createIngredient(name: _name, frequency: _frequency)
      : AppDatabase.updateIngredient(id: _id!, name: _name, frequency: _frequency);
    future.then((_) => search());
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(search);
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
                : Placeholder(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openDialog(),
        tooltip: "Add ingredient",
        child: Icon(CupertinoIcons.add),
      )
    );
  }

  Future openDialog([IngredientModel? ingredient]) {
    _id = ingredient?.id;
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ingredient?.name ?? "New Ingredient"),
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 100,
                autofocus: true,
                decoration: InputDecoration(label: Text("Name")),
                initialValue: ingredient?.name,
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
                initialValue: ingredient?.frequency,
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
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                saveIngredient();
                Navigator.of(context).pop();
              }
            },
            child: Text("SUBMIT"),
          ),
        ],
      ),
    );
  }
}