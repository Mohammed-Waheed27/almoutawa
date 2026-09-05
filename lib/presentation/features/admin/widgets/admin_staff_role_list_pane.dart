import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/layout/shell_scroll_insets.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/feedback/list_load_more_footer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/staff_profile.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../routes/app_routes.dart';
import '../bloc/delivery_workers_list_bloc.dart';
import '../layouts/admin_staff_list_desktop_body.dart';
import 'delivery_worker_list_card.dart';
import 'delivery_workers_list_skeleton.dart';
import 'delivery_workers_search_section.dart';

/// One staff-role list pane — keeps its own scroll + filter; no cross-tab reload.
class AdminStaffRoleListPane extends StatefulWidget {
  const AdminStaffRoleListPane({
    super.key,
    required this.role,
    required this.onOpenForm,
  });

  final UserRole role;
  final Future<void> Function({String? editPath, Object? extra}) onOpenForm;

  @override
  State<AdminStaffRoleListPane> createState() => _AdminStaffRoleListPaneState();
}

class _AdminStaffRoleListPaneState extends State<AdminStaffRoleListPane> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  DeliveryWorkerListFilter _filter = DeliveryWorkerListFilter.all;
  String _query = '';
  String? _selectedId;

  bool get _isOps => widget.role == UserRole.productionManager;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<DeliveryWorkersListBloc>().add(
        const DeliveryWorkersListLoadMoreRequested(),
      );
    }
  }

  bool _matchesQuery(StaffProfile worker) {
    if (_query.isEmpty) return true;
    final haystack =
        '${worker.displayName} ${worker.email ?? ''} ${worker.phone ?? ''}'
            .toLowerCase();
    return haystack.contains(_query);
  }

  Future<void> _confirmDelete(String profileId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(_isOps ? 'حذف مدير التشغيل' : 'حذف المندوب'),
          content: Text(
            _isOps
                ? 'هل أنت متأكد من حذف مدير التشغيل؟'
                : 'هل أنت متأكد من حذف هذا المندوب؟',
          ),
          actions: [
            AlmoutawaButton(
              label: 'إلغاء',
              variant: AlmoutawaButtonVariant.secondaryGlass,
              size: AlmoutawaButtonSize.sm,
              expanded: false,
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            AlmoutawaButton(
              label: 'حذف',
              variant: AlmoutawaButtonVariant.destructive,
              size: AlmoutawaButtonSize.sm,
              expanded: false,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true && mounted) {
      context.read<DeliveryWorkersListBloc>().add(
        DeliveryWorkerDeleteRequested(profileId),
      );
    }
  }

  void _toggleActive(StaffProfile worker) {
    if (worker.isActive) {
      context.read<DeliveryWorkersListBloc>().add(
        DeliveryWorkerSuspendRequested(worker.id),
      );
    } else {
      context.read<DeliveryWorkersListBloc>().add(
        DeliveryWorkerReactivateRequested(worker.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;

    return BlocConsumer<DeliveryWorkersListBloc, DeliveryWorkersListState>(
      listenWhen: (previous, current) =>
          previous.message != current.message ||
          previous.actionMessage != current.actionMessage,
      listener: (context, state) {
        final message = state.actionMessage ?? state.message;
        if (message != null) {
          AlmoutawaSnackbar.show(context, message);
        }
      },
      builder: (context, state) {
        if (state.showBlockingSpinner) {
          return const DeliveryWorkersListSkeleton();
        }

        final filtered = state.workers
            .where(_filter.matches)
            .where(_matchesQuery)
            .toList();

        final selectedStillVisible =
            _selectedId != null && filtered.any((w) => w.id == _selectedId);
        final effectiveSelectedId = selectedStillVisible
            ? _selectedId
            : (filtered.isEmpty ? null : filtered.first.id);

        if (dense) {
          return AdminStaffListDesktopBody(
            role: widget.role,
            workers: state.workers,
            filtered: filtered,
            filter: _filter,
            searchController: _searchController,
            selectedId: effectiveSelectedId,
            isLoadingMore: state.isLoadingMore,
            hasMore: state.hasMore,
            totalCount: state.totalCount,
            onFilterChanged: (value) => setState(() => _filter = value),
            onSelect: (id) => setState(() => _selectedId = id),
            onCreate: () => widget.onOpenForm(extra: widget.role),
            onRefresh: () => context.read<DeliveryWorkersListBloc>().add(
              const DeliveryWorkersListRefreshRequested(),
            ),
            onEdit: (worker) => widget.onOpenForm(
              editPath: AppRoutes.adminWorkerEditPath(worker.id),
              extra: worker,
            ),
            onToggleActive: _toggleActive,
            onDelete: (worker) => _confirmDelete(worker.id),
            scrollController: _scrollController,
          );
        }

        return RefreshIndicator(
          color: AppColors.secondaryContainer,
          backgroundColor: AppColors.surfaceContainerHighest,
          onRefresh: () async {
            context.read<DeliveryWorkersListBloc>().add(
              const DeliveryWorkersListRefreshRequested(),
            );
            await context.read<DeliveryWorkersListBloc>().stream.firstWhere(
              (next) =>
                  next.status != DeliveryWorkersListStatus.loading ||
                  next.workers.isNotEmpty,
            );
          },
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: ShellScrollInsets.tabListPaddingNoTop(context),
            children: [
              DeliveryWorkersSearchSection(
                controller: _searchController,
                selectedFilter: _filter,
                onFilterChanged: (value) => setState(() => _filter = value),
              ),
              SizedBox(height: AppSpacing.md),
              if (filtered.isEmpty)
                EmptyStateWidget(
                  message: _isOps
                      ? 'لا يوجد مديرو تشغيل مطابقون للبحث'
                      : 'لا يوجد مندوبي تسليم مطابقون للبحث',
                  icon: _isOps
                      ? Icons.precision_manufacturing_outlined
                      : Icons.local_shipping_outlined,
                )
              else
                ...filtered.map(
                  (worker) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: DeliveryWorkerListCard(
                      worker: worker,
                      onEdit: () => widget.onOpenForm(
                        editPath: AppRoutes.adminWorkerEditPath(worker.id),
                        extra: worker,
                      ),
                      onToggleActive: () => _toggleActive(worker),
                      onDelete: () => _confirmDelete(worker.id),
                    ),
                  ),
                ),
              ListLoadMoreFooter(
                isLoading: state.isLoadingMore,
                hasMore: state.hasMore,
                itemCount: state.workers.length,
                totalCount: state.totalCount,
              ),
            ],
          ),
        );
      },
    );
  }
}
