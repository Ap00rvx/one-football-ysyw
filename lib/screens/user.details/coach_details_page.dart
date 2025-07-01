import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ysyw/bloc/coach/coach_bloc.dart';
import 'package:ysyw/services/common_service.dart';
import '../../model/coach.dart';

class CoachDetailsPage extends StatefulWidget {
  final String email;
  final String name;
  final String userId;

  const CoachDetailsPage({
    super.key,
    required this.email,
    required this.name,
    required this.userId,
  });

  @override
  State<CoachDetailsPage> createState() => _CoachDetailsPageState();
}

class _CoachDetailsPageState extends State<CoachDetailsPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Services
  final CommonService _commonService = CommonService();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _certificationController = TextEditingController();

  // Form data
  String? _profileImagePath;
  String? _profileImageUrl;
  bool _isUploadingImage = false;
  List<String> _certifications = [];
  String _selectedSpecialty = '';
  final List<String> _specialtyOptions = [
    'Fitness Training',
    'Technical Skills',
    'Tactical Analysis',
    'Goalkeeping',
    'Youth Development',
    'Strength & Conditioning',
    'Sports Psychology',
    'Nutrition & Diet',
    'Injury Prevention',
    'Match Analysis',
  ];

  // Validation
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedSpecialty = _specialtyOptions.first;
    _specialtyController.text = _selectedSpecialty;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _experienceController.dispose();
    _certificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Coach Profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<CoachBloc, CoachState>(
        listener: (context, state) {
          if (state.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: colorScheme.error,
              ),
            );
          } else if (state.isSuccess && state.currentCoach != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Coach profile created successfully!'),
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
                  _buildProfilePictureStep(),
                  _buildExpertiseStep(),
                  _buildCertificationsStep(),
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
                    color: isActive ? colorScheme.onPrimary : colorScheme.outline,
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
              'Let\'s start with your coaching details',
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

            // Phone Number
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Iconsax.call),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Years of Experience
            TextFormField(
              controller: _experienceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Years of Experience',
                prefixIcon: const Icon(Iconsax.calendar_tick),
                suffixText: 'years',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your years of experience';
                }
                final experience = int.tryParse(value);
                if (experience == null || experience < 0) {
                  return 'Please enter a valid number of years';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Picture',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a professional photo to help students recognize you',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Profile Picture
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isUploadingImage ? null : _pickImage,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: _isUploadingImage
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : _profileImagePath != null
                              ? ClipOval(
                                  child: Image.file(
                                    File(_profileImagePath!),
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Iconsax.camera,
                                      size: 40,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_profileImagePath != null) ...[
                    ElevatedButton.icon(
                      onPressed: _isUploadingImage ? null : _pickImage,
                      icon: const Icon(Iconsax.edit),
                      label: const Text('Change Photo'),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _isUploadingImage
                          ? null
                          : () {
                              setState(() {
                                _profileImagePath = null;
                                _profileImageUrl = null;
                              });
                            },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isUploadingImage ? null : () => _pickImage(ImageSource.camera),
                          icon: const Icon(Iconsax.camera),
                          label: const Text('Camera'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _isUploadingImage ? null : () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Iconsax.gallery),
                          label: const Text('Gallery'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertiseStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coaching Expertise',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your primary coaching specialty',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Specialty Selection
            Text(
              'Primary Specialty',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            // Specialty Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _specialtyOptions.length,
              itemBuilder: (context, index) {
                final specialty = _specialtyOptions[index];
                final isSelected = _selectedSpecialty == specialty;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpecialty = specialty;
                      _specialtyController.text = specialty;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      specialty,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Certifications',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your coaching certifications and qualifications',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 32),

            // Add certification field
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _certificationController,
                    decoration: InputDecoration(
                      labelText: 'Add Certification',
                      prefixIcon: const Icon(Iconsax.award),
                      hintText: 'e.g., UEFA A License, NASM-CPT',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addCertification,
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Certifications list
            if (_certifications.isNotEmpty) ...[
              Text(
                'Your Certifications:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...List.generate(_certifications.length, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.award,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_certifications[index])),
                      IconButton(
                        onPressed: () => _removeCertification(index),
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Iconsax.award,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No certifications added yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add your professional certifications to build trust',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
            child: BlocBuilder<CoachBloc, CoachState>(
              builder: (context, state) {
                final isLoading = state.isLoading || _isUploadingImage;
                final isLastStep = _currentStep == _totalSteps - 1;

                return ElevatedButton(
                  onPressed: isLoading ? null : (isLastStep ? _submitForm : _nextStep),
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

  Future<void> _pickImage([ImageSource? source]) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source ?? ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImagePath = pickedFile.path;
          _isUploadingImage = true;
        });

        // Upload image to Cloudinary
        try {
          final imageUrl = await _commonService.uploadImageWithValidation(
            filePath: pickedFile.path,
            fileName: 'coach_profile_${widget.userId}.jpg',
            maxSizeInMB: 5,
          );

          setState(() {
            _profileImageUrl = imageUrl;
            _isUploadingImage = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          setState(() {
            _isUploadingImage = false;
            _profileImagePath = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload image: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addCertification() {
    if (_certificationController.text.isNotEmpty) {
      setState(() {
        _certifications.add(_certificationController.text.trim());
        _certificationController.clear();
      });
    }
  }

  void _removeCertification(int index) {
    setState(() {
      _certifications.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      final coachBloc = context.read<CoachBloc>();
      

      coachBloc.add(CreateCoachEvent(
        name: widget.name,
        userId: widget.userId,
        email: widget.email,
        coachingSpecialty: _selectedSpecialty,
        experienceYears: int.parse(_experienceController.text),
        phone: _phoneController.text.trim(),
        profilePicture: _profileImageUrl,
        certifications: _certifications,
        students: [], // Empty initially
      ));
    }
  }
}