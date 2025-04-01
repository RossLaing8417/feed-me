import 'package:flutter/material.dart';

class NumericStepButton extends StatefulWidget {
  final int? initialValue;
  final int minValue;
  final int maxValue;

  final ValueChanged<int>? onChanged;

  const NumericStepButton({
    super.key,
    this.initialValue,
    required this.minValue,
    required this.maxValue,
    this.onChanged,
  });

  @override
  State<NumericStepButton> createState() => _NumericStepButtonState();
}

class _NumericStepButtonState extends State<NumericStepButton> {
  int counter = 0;

  @override
  void initState() {
    counter = widget.initialValue ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(
            Icons.remove,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
          iconSize: 32.0,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            setState(() {
              if (counter > widget.minValue) {
                counter--;
              }
              if (widget.onChanged != null) widget.onChanged!(counter);
            });
          },
        ),
        Text(
          '$counter',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
          iconSize: 32.0,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            setState(() {
              if (counter < widget.maxValue) {
                counter++;
              }
              if (widget.onChanged != null) widget.onChanged!(counter);
            });
          },
        ),
      ],
    );
  }
}

class NumericStepButtonFormField extends FormField<int> {
  NumericStepButtonFormField({
    super.key,
    required int minValue,
    required int maxValue,
    InputDecoration? decoration,
    super.onSaved,
    super.forceErrorText,
    super.validator,
    super.initialValue,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
  }) : super(
         builder:
             (field) => Column(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 InputDecorator(
                   decoration: (decoration ?? InputDecoration()).copyWith(
                     errorText: field.errorText,
                   ),
                   child: NumericStepButton(
                     initialValue: field.value,
                     minValue: minValue,
                     maxValue: maxValue,
                     onChanged: field.didChange,
                   ),
                 ),
               ],
             ),
       );
}
