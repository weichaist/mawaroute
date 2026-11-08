import 'package:flutter/material.dart';

import '../../utility.dart';

class DateTimeInput extends StatefulWidget {
  final String labelText;
  final DateTime initialValue;
  final Function onDateSelected;
  const DateTimeInput({
    super.key,
    required this.labelText,
    required this.initialValue,
    required this.onDateSelected,
  });

  @override
  State<DateTimeInput> createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.text = dateString(widget.initialValue);
    return GestureDetector(
      onTap: () async {
        DateTime oldDate = widget.initialValue;
        DateTime? newDate = await showDatePicker(
            context: context,
            firstDate: widget.initialValue.subtract(const Duration(days: 365)),
            lastDate: widget.initialValue.add(const Duration(days: 365)),
            initialDate: widget.initialValue,
            initialEntryMode: DatePickerEntryMode.calendarOnly);
        if (!context.mounted) return;
        if (newDate != null) {
          newDate = DateTime(newDate.year, newDate.month, newDate.day,
              oldDate.hour, oldDate.minute, oldDate.second);
          TimeOfDay? time = await showTimePicker(
            context: context,
            initialEntryMode: TimePickerEntryMode.inputOnly,
            initialTime: TimeOfDay.fromDateTime(widget.initialValue),
          );
          if (time != null) {
            newDate = DateTime(newDate.year, newDate.month, newDate.day,
                time.hour, time.minute, newDate.second);
          }
          controller.text = dateString(newDate);
          widget.onDateSelected(newDate);
        }
      },
      child: ListTile(
        trailing: const Icon(Icons.event_note),
        title: TextField(
          enabled: false,
          controller: controller,
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: Colors.black45),
            errorStyle: const TextStyle(color: Colors.redAccent),
            border: const OutlineInputBorder(),
            labelText: widget.labelText,
          ),
        ),
      ),
    );
  }
}
