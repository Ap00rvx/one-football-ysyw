import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../bloc/competetion/competetion_bloc.dart';
import '../../../model/competetion_response_model.dart';

class MatchDataPage extends StatefulWidget {
  const MatchDataPage({super.key});

  @override
  State<MatchDataPage> createState() => _MatchDataPageState();
}

class _MatchDataPageState extends State<MatchDataPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load competitions when page initializes
    context.read<CompetetionBloc>().add(GetCompetitionsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Sport Your World',
            style: TextStyle(
  

                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontStyle: FontStyle.italic)),
        foregroundColor: colorScheme.onSurface,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          BlocBuilder<CompetetionBloc, CompetetionState>(
            builder: (context, state) {
              return IconButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        context
                            .read<CompetetionBloc>()
                            .add(RefreshCompetitionsEvent());
                      },
                icon: state.isRefreshing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary),
                        ),
                      )
                    : const Icon(Iconsax.refresh),
              );
            },
          ),
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: const Icon(Iconsax.filter),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Leagues'),
            Tab(text: 'Cups'),
          ],
        ),
      ),
      body: BlocConsumer<CompetetionBloc, CompetetionState>(
        listener: (context, state) {
          if (state.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: colorScheme.error,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: colorScheme.onError,
                  onPressed: () {
                    context.read<CompetetionBloc>().add(GetCompetitionsEvent());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search and filter summary
              _buildSearchAndSummary(state),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCompetitionsList(state.filteredCompetitions, state),
                    _buildCompetitionsList(
                      state.filteredCompetitions
                          .where((c) => c.type == Type.LEAGUE)
                          .toList(),
                      state,
                    ),
                    _buildCompetitionsList(
                      state.filteredCompetitions
                          .where((c) => c.type == Type.CUP)
                          .toList(),
                      state,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndSummary(CompetetionState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search competitions...',
              prefixIcon: const Icon(Iconsax.search_normal),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context
                            .read<CompetetionBloc>()
                            .add(const SearchCompetitionsEvent(''));
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (query) {
              context
                  .read<CompetetionBloc>()
                  .add(SearchCompetitionsEvent(query));
            },
          ),
          const SizedBox(height: 12),

          // Summary and filters
          Row(
            children: [
              Text(
                '${state.filteredCompetitions.length} of ${state.competitions.length} competitions',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const Spacer(),
              if (state.hasFilters)
                TextButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    context.read<CompetetionBloc>().add(ClearFiltersEvent());
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear filters'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionsList(
      List<Competition> competitions, CompetetionState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading competitions...'),
          ],
        ),
      );
    }

    if (competitions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_normal,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              state.hasFilters
                  ? 'No competitions match your filters'
                  : 'No competitions available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (state.hasFilters) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  context.read<CompetetionBloc>().add(ClearFiltersEvent());
                },
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CompetetionBloc>().add(RefreshCompetitionsEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: competitions.length,
        itemBuilder: (context, index) {
          final competition = competitions[index];
          return _buildCompetitionCard(competition);
        },
      ),
    );
  }

  Widget _buildCompetitionCard(Competition competition) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showCompetitionDetails(competition);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Competition emblem
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        competition.emblem,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Iconsax.cup,
                            color: colorScheme.primary,
                            size: 24,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Competition info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          competition.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (competition.area.flag != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: Image.network(
                                  competition.area.flag!,
                                  width: 16,
                                  height: 12,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 16,
                                      height: 12,
                                      color: Colors.grey[300],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                '${competition.area.name} • ${competition.code}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Competition badges
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildCompetitionBadge(
                    competition.type.name,
                    competition.type == Type.LEAGUE
                        ? Colors.blue
                        : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  _buildCompetitionBadge(
                    competition.plan.name.replaceAll('_', ' '),
                    competition.plan == Plan.TIER_ONE
                        ? Colors.amber
                        : Colors.grey,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Season info
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.calendar,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Season: ${DateFormat('MMM yyyy').format(competition.currentSeason.startDate)} - ${DateFormat('MMM yyyy').format(competition.currentSeason.endDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (competition.currentSeason.currentMatchday > 0)
                      Text(
                        'MD ${competition.currentSeason.currentMatchday}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompetitionBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color.withOpacity(0.8),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocBuilder<CompetetionBloc, CompetetionState>(
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Filter Competitions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      if (state.hasFilters)
                        TextButton(
                          onPressed: () {
                            context
                                .read<CompetetionBloc>()
                                .add(ClearFiltersEvent());
                            Navigator.pop(context);
                          },
                          child: const Text('Clear All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Competition Type',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterChip(
                          'Leagues',
                          state.selectedType == Type.LEAGUE,
                          () {
                            context.read<CompetetionBloc>().add(
                                  FilterCompetitionsByTypeEvent(
                                      state.selectedType == Type.LEAGUE
                                          ? null
                                          : Type.LEAGUE),
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterChip(
                          'Cups',
                          state.selectedType == Type.CUP,
                          () {
                            context.read<CompetetionBloc>().add(
                                  FilterCompetitionsByTypeEvent(
                                      state.selectedType == Type.CUP
                                          ? null
                                          : Type.CUP),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Competition Plan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFilterChip(
                          'Tier One',
                          state.selectedPlan == Plan.TIER_ONE,
                          () {
                            context.read<CompetetionBloc>().add(
                                  FilterCompetitionsByPlanEvent(
                                      state.selectedPlan == Plan.TIER_ONE
                                          ? null
                                          : Plan.TIER_ONE),
                                );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildFilterChip(
                          'Tier Four',
                          state.selectedPlan == Plan.TIER_FOUR,
                          () {
                            context.read<CompetetionBloc>().add(
                                  FilterCompetitionsByPlanEvent(
                                      state.selectedPlan == Plan.TIER_FOUR
                                          ? null
                                          : Plan.TIER_FOUR),
                                );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected ? colorScheme.primary : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? colorScheme.primary : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  void _showCompetitionDetails(Competition competition) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Image.network(
                competition.emblem,
                width: 32,
                height: 32,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Iconsax.cup, size: 32);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  competition.name,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Area', competition.area.name),
              _buildDetailRow('Code', competition.code),
              _buildDetailRow('Type', competition.type.name),
              _buildDetailRow(
                  'Plan', competition.plan.name.replaceAll('_', ' ')),
              _buildDetailRow('Current Matchday',
                  '${competition.currentSeason.currentMatchday}'),
              _buildDetailRow('Available Seasons',
                  '${competition.numberOfAvailableSeasons}'),
              if (competition.currentSeason.winner != null)
                _buildDetailRow(
                    'Current Winner', competition.currentSeason.winner!.name),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
