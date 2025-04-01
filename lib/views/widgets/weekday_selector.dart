import 'package:feedme/core/weekday.dart';
import 'package:flutter/material.dart';

class WeekdaySelector extends FormField<Weekday> {
  WeekdaySelector({
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.validator,
    super.initialValue,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    InputDecoration? decoration,
  }) : super(
         builder: (field) {
           final text = <String>[];
           final selected = <bool>[];
           for (var i = 1; i <= 7; i += 1) {
             text.add(Weekday.fromDay(i).toString());
             selected.add(field.value?.hasDay(i) ?? false);
           }
           return Row(
             children: [
               Expanded(
                 child: InputDecorator(
                   decoration: (decoration ?? InputDecoration()).copyWith(
                     errorText: field.errorText,
                   ),
                   child: ToggleButtons(
                     isSelected: selected,
                     children: text.map((e) => Text(e[0])).toList(),
                     onPressed: (index) {
                       final weekday = field.value ?? Weekday.none;
                       weekday.toggleDay(index + 1);
                       field.didChange(weekday);
                     },
                   ),
                 ),
               ),
             ],
           );
         },
       );
}

/*
import 'package:feedme/core/weekday.dart';
import 'package:flutter/material.dart';

class WeekdaySelectorController extends ValueNotifier<Weekday> {
  WeekdaySelectorController({Weekday? weekday})
    : super(weekday ?? Weekday.none);
  WeekdaySelectorController.fromValue(Weekday? weekday)
    : super(weekday ?? Weekday.none);
  Weekday get weekday => value;
  set weekday(Weekday newWeekday) => value = newWeekday;
  clear() => value = Weekday.none;
}

class WeekdaySelector extends StatefulWidget {
  const WeekdaySelector({super.key, this.controller, this.onChanged});

  final ValueChanged<Weekday>? onChanged;
  final WeekdaySelectorController? controller;

  @override
  State<WeekdaySelector> createState() => _WeekdaySelectorState();
}

class _WeekdaySelectorState extends State<WeekdaySelector> {
  final text = <String>["M", "T", "W", "T", "F", "S", "S"];
  final selected = List<bool>.filled(7, false);

  WeekdaySelectorController? _controller;
  WeekdaySelectorController get _effectiveController => widget.controller ?? _controller!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = WeekdaySelectorController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: selected,
      children: text.map((element) => Text(element)).toList(),
      onPressed: (index) {
        setState(() {
          selected[index] = !selected[index];
          _effectiveController.value.toggleDay(index + 1);
        });
        // final weekday = field.value ?? Weekday.none;
        // weekday.toggleDay(index + 1);
        // field.didChange(weekday);
      },
    );
  }
}

class WeekdaySelectorFormField extends FormField<Weekday> {
  WeekdaySelectorFormField({
    super.key,
    super.onSaved,
    super.forceErrorText,
    super.validator,
    super.initialValue,
    super.enabled,
    super.autovalidateMode,
    super.restorationId,
    String? label,
  }) : super(
    builder: (field) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null) Text(label, textAlign: TextAlign.left),
          WeekdaySelector(),
          if (field.hasError)
            Text(field.errorText ?? "", style: TextStyle(color: Colors.red))
        ],
      );
    },
  );
}
*/
