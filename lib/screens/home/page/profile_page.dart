import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ysyw/bloc/profile/profile_bloc.dart';
import 'package:ysyw/model/profile.dart';

import '../../../services/common_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CommonService _commonService = CommonService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;
  bool _isDeletingImage = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(state.errorMessage ?? 'An error occurred'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && !state.hasProfile) {
            return const _LoadingView();
          }

          if (!state.hasProfile) {
            return const _NoProfileView();
          }

          return _ProfileView(
            state: state,
            tabController: _tabController,
            onImageUpload: _handleImageUpload,
            isUploadingImage: _isUploadingImage,
            onDeleteImage: () {
              if (_isDeletingImage) return;
              if (state.userProfilePicture == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No profile picture to delete')),
                );
                return;
              }
              context.read<ProfileBloc>().add(DeleteProfilePictureEvent());
            },
          );
        },
      ),
    );
  }

  Future<void> _handleImageUpload(BuildContext context) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _isUploadingImage = true;
        });

        try {
          final imageUrl = await _commonService.uploadImageWithValidation(
            filePath: pickedFile.path,
            fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
            maxSizeInMB: 5,
          );

          if (mounted) {
            context.read<ProfileBloc>().add(UpdateBasicProfileEvent(
                  profilePicture: imageUrl,
                ));
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $e')),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isUploadingImage = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }
}

class _ProfileView extends StatelessWidget {
  final ProfileState state;
  final TabController tabController;
  final Function(BuildContext) onImageUpload;
  final bool isUploadingImage;
  final bool isDeletingImage = false;
  final Function() onDeleteImage;

  const _ProfileView({
    required this.state,
    required this.tabController,
    required this.onImageUpload,
    required this.isUploadingImage,
    required this.onDeleteImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    print('ProfileView: User Name: ${state.userProfilePicture.runtimeType}');

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 480,
          floating: false,
          pinned: true,
          backgroundColor: colorScheme.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Iconsax.refresh),
              onPressed: () {
                context.read<ProfileBloc>().add(RefreshProfileEvent());
              },
            ),
            IconButton(
              icon: const Icon(Iconsax.setting),
              onPressed: () {
                // Navigate to settings
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            expandedTitleScale: 1.5,
            centerTitle: false,
            background: Container(
                decoration: BoxDecoration(
                  image: state.userProfilePicture != null ||
                          state.userProfilePicture!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(
                            state.userProfilePicture ?? '',
                          ),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter)
                      : null,
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.white,
                      colorScheme.secondary.withOpacity(0.1),
                      colorScheme.secondary.withOpacity(0.1),
                      colorScheme.secondary.withOpacity(0.6),
                      colorScheme.primary.withOpacity(0.3),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    if (state.userProfilePicture == null ||
                        state.userProfilePicture!.isEmpty)
                      Center(
                        child: Text(
                          state.userName.isNotEmpty
                              ? state.userName[0].toUpperCase()
                              : 'UU',
                          style: const TextStyle(
                            fontSize: 100,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Visibility(
                        visible: state.userProfilePicture != null &&
                            state.userProfilePicture!.isNotEmpty,
                        child: Container(
                          height: 600,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black87
                                ]),
                          ),
                        )),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.primaryContainer,
                          ),
                          icon: Row(
                            children: [
                              CircleAvatar(
                                child: Icon(
                                  Iconsax.camera4,
                                  size: 24,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                isUploadingImage
                                    ? 'Uploading...'
                                    : 'Change Photo',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          onPressed: () => onImageUpload(context)),
                    ),
                    Visibility(
                      visible: state.userProfilePicture != null &&
                          state.userProfilePicture!.isNotEmpty,
                      child: Positioned(
                        bottom: 16,
                        right: 16,
                        child: IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.transparent,
                            ),
                            icon: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red.withOpacity(1),
                                  child: const Icon(
                                    Iconsax.trash,
                                    size: 24,
                                    color: Colors.white,
                                  ),
                                ),
                                if (isDeletingImage)
                                  const SizedBox(
                                    width: 10,
                                  ),
                                Text(
                                  isDeletingImage ? 'Deleting...' : '',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () => onDeleteImage()),
                      ),
                    ),
                  ],
                )),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      state.userName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        state.userRole?.toUpperCase() ?? 'USER',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                _ProfileStats(state: state),
                const SizedBox(height: 24),
                _ProfileTabs(
                  state: state,
                  tabController: tabController,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileImage extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final VoidCallback onTap;
  final bool isUploading;

  const _ProfileImage({
    this.imageUrl,
    required this.name,
    required this.onTap,
    required this.isUploading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: isUploading
                    ? Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : imageUrl != null
                        ? Image.network(
                            imageUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _DefaultAvatar(name: name);
                            },
                          )
                        : _DefaultAvatar(name: name),
              ),
            ),
            if (!isUploading)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Iconsax.camera,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  final String name;

  const _DefaultAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final ProfileState state;

  const _ProfileStats({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Iconsax.user,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Iconsax.sms,
            label: 'Email',
            value: state.userEmail,
          ),
          if (state.userPhone != null)
            _InfoRow(
              icon: Iconsax.call,
              label: 'Phone',
              value: state.userPhone!,
            ),
          _InfoRow(
            icon: Iconsax.user_tag,
            label: 'Role',
            value: state.userRole ?? 'Unknown',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  final ProfileState state;
  final TabController tabController;

  const _ProfileTabs({
    required this.state,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Settings'),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: tabController,
            children: [
              _DetailsTab(state: state),
              _SettingsTab(state: state),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final ProfileState state;

  const _DetailsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isStudent && state.studentProfile != null) {
      return _StudentDetails(student: state.studentProfile!);
    } else if (state.isCoach && state.coachProfile != null) {
      return _CoachDetails(coach: state.coachProfile!);
    } else {
      return const Center(
        child: Text('No role-specific profile found'),
      );
    }
  }
}

class _StudentDetails extends StatelessWidget {
  final StudentProfile student;

  const _StudentDetails({required this.student});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _DetailCard(
            title: 'Athletic Information',
            icon: Iconsax.activity,
            children: [
              _DetailItem(
                label: 'Jersey Number',
                value: student.jerseyNumber,
                icon: Iconsax.medal,
              ),
              _DetailItem(
                label: 'Height',
                value: '${student.height} cm',
                icon: Iconsax.ruler,
              ),
              _DetailItem(
                label: 'Weight',
                value: '${student.weight} kg',
                icon: Iconsax.weight,
              ),
              _DetailItem(
                label: 'Date of Birth',
                value: DateFormat('MMM dd, yyyy').format(student.dob),
                icon: Iconsax.calendar,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (student.highLights.isNotEmpty)
            _DetailCard(
              title: 'Highlights',
              icon: Iconsax.star,
              children: [
                ...student.highLights.map(
                  (highlight) => _HighlightItem(
                    highlight: highlight,
                    onRemove: () {
                      context
                          .read<ProfileBloc>()
                          .add(RemoveHighlightEvent(highlight));
                    },
                  ),
                ),
                _AddHighlightButton(),
              ],
            ),
          if (student.metrics.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailCard(
              title: 'Performance Metrics',
              icon: Iconsax.chart,
              children: student.metrics
                  .map((metric) => _MetricItem(metric: metric))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _CoachDetails extends StatelessWidget {
  final CoachProfile coach;

  const _CoachDetails({required this.coach});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _DetailCard(
            title: 'Coaching Information',
            icon: Iconsax.teacher,
            children: [
              _DetailItem(
                label: 'Specialty',
                value: coach.coachingSpecialty,
                icon: Iconsax.medal_star,
              ),
              _DetailItem(
                label: 'Experience',
                value: '${coach.experienceYears} years',
                icon: Iconsax.clock,
              ),
              _DetailItem(
                label: 'Students',
                value: '${coach.students.length}',
                icon: Iconsax.people,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (coach.certifications.isNotEmpty)
            _DetailCard(
              title: 'Certifications',
              icon: Iconsax.award,
              children: [
                ...coach.certifications.map(
                  (cert) => _CertificationItem(
                    certification: cert,
                    onRemove: () {
                      context
                          .read<ProfileBloc>()
                          .add(RemoveCertificationEvent(cert));
                    },
                  ),
                ),
                _AddCertificationButton(),
              ],
            ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            '${label[0].toUpperCase()}${label.substring(1)}:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final String highlight;
  final VoidCallback onRemove;

  const _HighlightItem({
    required this.highlight,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Iconsax.star,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
              child: Text(highlight,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ))),
          IconButton(
            icon: Icon(Icons.close,
                size: 16,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _CertificationItem extends StatelessWidget {
  final String certification;
  final VoidCallback onRemove;

  const _CertificationItem({
    required this.certification,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.award, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(certification)),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final PerformanceMetric metric;

  const _MetricItem({required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.chart_2, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${metric.metricType[0].toUpperCase()}${metric.metricType.substring(1)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Value: ${metric.value}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            DateFormat('MMM dd').format(metric.recordedAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AddHighlightButton extends StatefulWidget {
  @override
  State<_AddHighlightButton> createState() => _AddHighlightButtonState();
}

class _AddHighlightButtonState extends State<_AddHighlightButton> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Add a highlight...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                context
                    .read<ProfileBloc>()
                    .add(AddHighlightEvent(_controller.text));
                _controller.clear();
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _AddCertificationButton extends StatefulWidget {
  @override
  State<_AddCertificationButton> createState() =>
      _AddCertificationButtonState();
}

class _AddCertificationButtonState extends State<_AddCertificationButton> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Add certification...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                context
                    .read<ProfileBloc>()
                    .add(AddCertificationEvent(_controller.text));
                _controller.clear();
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  final ProfileState state;

  const _SettingsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _SettingItem(
            icon: Iconsax.edit,
            title: 'Edit Profile',
            subtitle: 'Update your profile information',
            onTap: () {
              _showEditProfileDialog(context, state);
            },
          ),
          _SettingItem(
            icon: Iconsax.key,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () {
              // Navigate to change password
            },
          ),
          _SettingItem(
            icon: Iconsax.notification,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              // Navigate to notification settings
            },
          ),
          _SettingItem(
            icon: Iconsax.security_safe,
            title: 'Privacy',
            subtitle: 'Privacy and security settings',
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          _SettingItem(
            icon: Iconsax.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () {
              _showLogoutDialog(context);
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditProfileSheet(state: state),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(ClearProfileEvent());
              context.go('/onboarding');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            isDestructive ? Colors.red : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final ProfileState state;

  const _EditProfileSheet({required this.state});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.userName);
    _phoneController =
        TextEditingController(text: widget.state.userPhone ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<ProfileBloc>().add(UpdateBasicProfileEvent(
                      name: _nameController.text,
                      phone: _phoneController.text,
                    ));
                Navigator.pop(context);
              },
              child: const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading profile...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoProfileView extends StatelessWidget {
  const _NoProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.user,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Profile Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Please complete your profile setup',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ProfileBloc>().add(GetProfileEvent());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
