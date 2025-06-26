import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../bloc/bloc/student_bloc.dart';
import '../../model/student.dart';

class StudentDetailsPage extends StatefulWidget {
  final String email;
  final String name;
  final String userId;

  const StudentDetailsPage({
    super.key,
    required this.email,
    required this.name,
    required this.userId,
  });

  @override
  State<StudentDetailsPage> createState() => _StudentDetailsPageState();
}

class _StudentDetailsPageState extends State<StudentDetailsPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form controllers
  final _dobController = TextEditingController();
  final _jerseyController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _highlightController = TextEditingController();

  // Form data
  DateTime? _selectedDate;
  List<String> _highlights = [];
  List<StudentMetric> _metrics = [];

  // Validation
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _dobController.dispose();
    _jerseyController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state.isSuccess && state.currentStudent != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to home
            context.go('/home');
          }
        },
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(colorScheme),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildBasicInfoStep(),
                  _buildPhysicalStatsStep(),
                  _buildHighlightsStep(),
                  _buildMetricsStep(),
                ],
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.circle,
                    color:
                        isActive ? colorScheme.onPrimary : colorScheme.outline,
                    size: 16,
                  ),
                ),
                if (index < _totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s start with your basic details',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Display pre-filled data
            _buildReadOnlyField('Full Name', widget.name, Iconsax.user),
            const SizedBox(height: 16),
            _buildReadOnlyField('Email', widget.email, Iconsax.sms),
            const SizedBox(height: 16),

            // Date of Birth
            TextFormField(
              controller: _dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date of Birth',
                prefixIcon: const Icon(Iconsax.calendar),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onTap: () => _selectDate(context),
              validator: (value) {
                if (_selectedDate == null) {
                  return 'Please select your date of birth';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Jersey Number
            TextFormField(
              controller: _jerseyController,
              decoration: InputDecoration(
                labelText: 'Jersey Number',
                prefixIcon: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  child: const Text(
                    "#",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your jersey number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalStatsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Physical Stats',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help scouts know your physical attributes',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Height
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                prefixIcon: const Icon(Iconsax.ruler),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your height';
                }
                final height = double.tryParse(value);
                if (height == null || height <= 0) {
                  return 'Please enter a valid height';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Weight
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                prefixIcon: const Icon(Iconsax.weight),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your weight';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return 'Please enter a valid weight';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your football achievements and highlights',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Add highlight field
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _highlightController,
                    decoration: InputDecoration(
                      labelText: 'Add Achievement',
                      prefixIcon: const Icon(Iconsax.star),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addHighlight,
                  icon: const Icon(Icons.add_circle),
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Highlights list
            if (_highlights.isNotEmpty) ...[
              Text(
                'Your Achievements:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...List.generate(_highlights.length, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_highlights[index])),
                      IconButton(
                        onPressed: () => _removeHighlight(index),
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rate your skills from 1-10 (optional)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Predefined metrics
            ..._buildMetricSliders(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMetricSliders() {
    final metricTypes = [
      'Speed',
      'Dribbling',
      'Passing',
      'Shooting',
      'Defending',
      'Physical',
    ];

    return metricTypes.map((type) {
      final existingMetric = _metrics
          .where((m) => m.metricType.toLowerCase() == type.toLowerCase())
          .firstOrNull;
      double currentValue = existingMetric?.value ?? 5.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$type: ${currentValue.toInt()}/10',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: currentValue,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _updateMetric(type.toLowerCase(), value);
              });
            },
          ),
          const SizedBox(height: 16),
        ],
      );
    }).toList();
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildNavigationButtons(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: BlocBuilder<StudentBloc, StudentState>(
              builder: (context, state) {
                final isLoading = state.isLoading;
                final isLastStep = _currentStep == _totalSteps - 1;

                return ElevatedButton(
                  onPressed:
                      isLoading ? null : (isLastStep ? _submitForm : _nextStep),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isLastStep ? 'Complete Profile' : 'Next'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_currentStep < _totalSteps - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().subtract(const Duration(days: 6570)), // ~18 years ago
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dobController.text = DateFormat('dd/MM/yyyy').format(date);
      });
    }
  }

  void _addHighlight() {
    if (_highlightController.text.isNotEmpty) {
      setState(() {
        _highlights.add(_highlightController.text);
        _highlightController.clear();
      });
    }
  }

  void _removeHighlight(int index) {
    setState(() {
      _highlights.removeAt(index);
    });
  }

  void _updateMetric(String type, double value) {
    final existingIndex = _metrics
        .indexWhere((m) => m.metricType.toLowerCase() == type.toLowerCase());
    if (existingIndex != -1) {
      _metrics[existingIndex] = StudentMetric(metricType: type, value: value);
    } else {
      _metrics.add(StudentMetric(metricType: type, value: value));
    }
  }

  void _submitForm() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      final studentBloc = context.read<StudentBloc>();

      studentBloc.add(CreateStudentEvent(
        name: widget.name,
        userId: widget.userId,
        email: widget.email,
        dob: _selectedDate!,
        jerseyNumber: _jerseyController.text,
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
        highLights: _highlights,
        metrics: _metrics,
      ));
    }
  }
}
