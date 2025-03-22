import 'package:flutter/material.dart';

class NumericStepButton extends StatefulWidget {
  final int minValue;
  final int maxValue;

  final ValueChanged<int>? onChanged;

  NumericStepButton({
    super.key,
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
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(
            Icons.remove,
            // color: Theme.of(context).accentColor,
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
            color: Colors.black87,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add,
            // color: Theme.of(context).accentColor,
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
    String? label,
    super.onSaved,
    super.forceErrorText,
    super.validator,
    super.initialValue,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
  }) : super(
    builder: (field) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Text(label, textAlign: TextAlign.left),
        NumericStepButton(
          minValue: minValue,
          maxValue: maxValue,
          onChanged: field.didChange,
        ),
        if (field.hasError)
          Text(field.errorText ?? "", style: TextStyle(color: Colors.red)),
      ],
    ),
  );
}