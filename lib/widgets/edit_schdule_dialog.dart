
// Edit Schedule Dialog (Similar to Create but with pre-filled values)
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:ysyw/model/schedule.dart';

class EditScheduleDialog extends StatefulWidget {
  final Schedule schedule;
  final Function(
    String title,
    String? description,
    DateTime date,
    DateTime? endDate,
    String location,
    ScheduleType type,
    int? maxAttendees,
    String? notes,
  ) onUpdateSchedule;

  const EditScheduleDialog({
    super.key,
    required this.schedule,
    required this.onUpdateSchedule,
  });

  @override
  State<EditScheduleDialog> createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends State<EditScheduleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _maxAttendeesController;
  late TextEditingController _notesController;

  late DateTime _selectedDate;
  late DateTime? _selectedEndDate;
  late ScheduleType _selectedType;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.schedule.title);
    _descriptionController =
        TextEditingController(text: widget.schedule.description ?? '');
    _locationController = TextEditingController(text: widget.schedule.location);
    _maxAttendeesController = TextEditingController(
      text: widget.schedule.maxAttendees?.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.schedule.notes ?? '');
    _selectedDate = widget.schedule.date;
    _selectedEndDate = widget.schedule.endDate;
    _selectedType = widget.schedule.type;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      constraints: const BoxConstraints(maxHeight: 700),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Text(
                  'Edit Schedule',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ScheduleType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ScheduleType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Date'),
                            subtitle: Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                            ),
                            trailing: const Icon(Iconsax.calendar),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() {
                                  _selectedDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    _selectedDate.hour,
                                    _selectedDate.minute,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('Time'),
                            subtitle: Text(
                              DateFormat('HH:mm').format(_selectedDate),
                            ),
                            trailing: const Icon(Iconsax.clock),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime:
                                    TimeOfDay.fromDateTime(_selectedDate),
                              );
                              if (time != null) {
                                setState(() {
                                  _selectedDate = DateTime(
                                    _selectedDate.year,
                                    _selectedDate.month,
                                    _selectedDate.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _maxAttendeesController,
                      decoration: const InputDecoration(
                        labelText: 'Max Attendees (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onUpdateSchedule(
                          _titleController.text,
                          _descriptionController.text.isEmpty
                              ? null
                              : _descriptionController.text,
                          _selectedDate,
                          _selectedEndDate,
                          _locationController.text,
                          _selectedType,
                          _maxAttendeesController.text.isEmpty
                              ? null
                              : int.tryParse(_maxAttendeesController.text),
                          _notesController.text.isEmpty
                              ? null
                              : _notesController.text,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
