import 'dart:async';

import 'package:feedme/database/database.dart';
import 'package:feedme/database/models/measurement.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppMeasurementsView extends StatefulWidget {
  const AppMeasurementsView({super.key});

  @override
  State<AppMeasurementsView> createState() => _AppMeasurementsViewState();
}

class _AppMeasurementsViewState extends State<AppMeasurementsView> {
  List<MeasurementModel> _measurements = [];
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  // TODO: Loading spinner?
  applyFilter(String filter) {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce?.cancel();
    }
    _searchDebounce = Timer(Duration(milliseconds: 200), () {
      setState(() {
        _measurements = AppDatabase.measurements.where((element)
          => element.label.toLowerCase().contains(filter.toLowerCase())).toList();
        _measurements.sort((a, b)
          => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
        // AppDatabase.fetchMeasurements(QueryOpts(
        //   filtering:  [
        //     FilterField(
        //         field: MeasurementFields.label,
        //         operator: FilterField.like,
        //         value: "%${filter.replaceAll(" ", "%")}%",
        //     )
        //   ],
        //   sorting: [SortField(field: MeasurementFields.name)],
        // ));
        _searchDebounce = null;
      });
    });
  }

  search() => applyFilter(_searchController.text);

  editMeasurement([int? id]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AppMeasurementEditView(id: id)),
    );
    search();
  }

  deleteMeasurement(int id) async {
    await AppDatabase.deleteMeasurement(id: id);
    search();
  }

  @override
  void initState() {
    _searchController.addListener(search);
    search();
    super.initState();
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
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          spacing: 16.0,
          children: [
            SearchBar(
              controller: _searchController,
              leading: Icon(CupertinoIcons.search),
              hintText: "Search...",
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    onPressed: () => setState(() => _searchController.clear()),
                    icon: Icon(CupertinoIcons.xmark),
                  ),
              ],
            ),
            Expanded(
              child: Center(
                child: _measurements.isEmpty
                ? Text("No measurements found")
                : ListView.builder(
                  itemCount: _measurements.length,
                  itemBuilder: (context, index) {
                    final measurement = _measurements[index];
                    return Expanded(child: Card(
                      child: ListTile(
                        onTap: () => editMeasurement(measurement.id!),
                        onLongPress: () => openDeleteDialog(measurement.id!),
                        title: Text(measurement.label),
                        titleTextStyle: Theme.of(context).textTheme.titleLarge,
                        subtitle: Text(measurement.description),
                        subtitleTextStyle: Theme.of(context).textTheme.titleSmall,
                      ),
                    ));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => editMeasurement(),
        tooltip: "Add measurement",
        child: Icon(CupertinoIcons.add),
      ),
    );
  }

  Future openDeleteDialog(int id) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure you want to delete this measurement"),
        actions: [
          FilledButton(
            onPressed: () {
              deleteMeasurement(id);
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

class AppMeasurementEditView extends StatefulWidget {
  final int? id;
  const AppMeasurementEditView({super.key, this.id});

  @override
  State<AppMeasurementEditView> createState() => _AppMeasurementEditViewState();
}

class _AppMeasurementEditViewState extends State<AppMeasurementEditView> {
  var _isNew = false;
  final _formKey = GlobalKey<FormState>();

  String _label = "";
  String _description = "";

  refresh() {
    if (widget.id == null) {
      setState(() {
        _isNew = true;
      });
      return;
    }
    final model = AppDatabase.measurements.firstWhere((element) => element.id == widget.id);
    setState(() {
      _label = model.label;
      _description = model.description;
    });
  }

  saveChanges(context) async {
    final _ = _isNew
      ? await AppDatabase.createMeasurement(
        label: _label,
        description: _description,
      )
      : await AppDatabase.updateMeasurement(
        id: widget.id!,
        label: _label,
        description: _description,
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
