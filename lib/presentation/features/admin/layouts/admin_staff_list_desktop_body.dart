import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/layout/desktop_master_list_tile.dart';
import '../../../../core/layout/master_detail_desktop_shell.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/feedback/list_load_more_footer.dart';
import '../../../../core/shared/widgets/layout/desktop_entity_header_strip.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/staff_profile.dart';
import '../../../../domain/entities/user_role.dart';
import '../widgets/delivery_workers_search_section.dart';

/// Expanded staff hub pane — filters sidebar + master list + action preview.
class AdminStaffListDesktopBody extends StatelessWidget {
  const AdminStaffListDesktopBody({
    super.key,
    required this.role,
    required this.workers,
    required this.filtered,
    required this.filter,
    required this.searchController,
    required this.selectedId,
    required this.isLoadingMore,
    required this.hasMore,
    required this.totalCount,
    required this.onFilterChanged,
    required this.onSelect,
    required this.onCreate,
    required this.onRefresh,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
    required this.scrollController,
  });

  final UserRole role;
  final List<StaffProfile> workers;
  final List<StaffProfile> filtered;
  final DeliveryWorkerListFilter filter;
  final TextEditingController searchController;
  final String? selectedId;
  final bool isLoadingMore;
  final bool hasMore;
  final int? totalCount;
  final ValueChanged<DeliveryWorkerListFilter> onFilterChanged;
  final ValueChanged<String?> onSelect;
  final VoidCallback onCreate;
  final VoidCallback onRefresh;
  final ValueChanged<StaffProfile> onEdit;
  final ValueChanged<StaffProfile> onToggleActive;
  final ValueChanged<StaffProfile> onDelete;
  final ScrollController scrollController;

  bool get _isOps => role == UserRole.productionManager;

  StaffProfile? get _selected {
    if (selectedId == null) return null;
    for (final w in filtered) {
      if (w.id == selectedId) return w;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MasterDetailDesktopShell(
      sidebarWidth: DesktopUiTokens.filterSidebarWidth,
      masterWidth: DesktopUiTokens.masterListMaxWidth,
      sidebar: ListView(
        padding: const EdgeInsets.all(DesktopUiTokens.pagePadding),
        children: [
          Text(
            _isOps ? 'مديرو التشغيل' : 'مندوبو التسليم',
            style: AppTypography.pageTitleOf(context),
          ),
          const SizedBox(height: DesktopUiTokens.gapMd),
          DeliveryWorkersSearchSection(
            controller: searchController,
            selectedFilter: filter,
            onFilterChanged: onFilterChanged,
          ),
          const SizedBox(height: DesktopUiTokens.gapLg),
          AlmoutawaButton(
            label: _isOps ? 'مدير تشغيل جديد' : 'مندوب جديد',
            icon: Icons.person_add_outlined,
            onPressed: onCreate,
          ),
          const SizedBox(height: DesktopUiTokens.gapSm),
          AlmoutawaButton(
            label: 'تحديث',
            icon: Icons.refresh_rounded,
            variant: AlmoutawaButtonVariant.secondaryGlass,
            onPressed: onRefresh,
          ),
        ],
      ),
      master: workers.isEmpty
          ? EmptyStateWidget(
              message: _isOps
                  ? 'لا يوجد مديرو تشغيل بعد'
                  : 'لا يوجد مندوبو تسليم بعد',
              icon: _isOps
                  ? Icons.precision_manufacturing_outlined
                  : Icons.local_shipping_outlined,
              actionLabel: _isOps ? 'مدير تشغيل جديد' : 'مندوب جديد',
              onAction: onCreate,
            )
          : filtered.isEmpty
          ? EmptyStateWidget(
              message: _isOps
                  ? 'لا يوجد مديرو تشغيل مطابقون للبحث'
                  : 'لا يوجد مندوبي تسليم مطابقون للبحث',
              icon: Icons.search_off_rounded,
            )
          : ListView.builder(
              controller: scrollController,
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == filtered.length) {
                  return ListLoadMoreFooter(
                    isLoading: isLoadingMore,
                    hasMore: hasMore,
                    itemCount: workers.length,
                    totalCount: totalCount ?? workers.length,
                  );
                }
                final worker = filtered[index];
                return DesktopMasterListTile(
                  selected: worker.id == selectedId,
                  title: worker.displayName,
                  subtitle: [
                    if (worker.phone?.trim().isNotEmpty == true)
                      worker.phone!.trim(),
                    worker.isActive ? 'نشط' : 'موقوف',
                  ].join(' · '),
                  trailing: Icon(
                    Icons.chevron_left_rounded,
                    size: DesktopUiTokens.iconSize,
                    color: worker.isActive
                        ? AppColors.success
                        : AppColors.onSurfaceVariant,
                  ),
                  onTap: () => onSelect(worker.id),
                );
              },
            ),
      detail: _selected == null
          ? null
          : _StaffPreview(
              worker: _selected!,
              isOps: _isOps,
              onEdit: () => onEdit(_selected!),
              onToggleActive: () => onToggleActive(_selected!),
              onDelete: () => onDelete(_selected!),
            ),
    );
  }
}

class _StaffPreview extends StatelessWidget {
  const _StaffPreview({
    required this.worker,
    required this.isOps,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  final StaffProfile worker;
  final bool isOps;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final phone = worker.phone?.trim().isNotEmpty == true
        ? worker.phone!.trim()
        : '—';
    final email = worker.email?.trim().isNotEmpty == true
        ? worker.email!.trim()
        : '—';
    final joined = DateFormat('yyyy/MM/dd', 'ar').format(worker.createdAt);

    return Padding(
      padding: const EdgeInsets.all(DesktopUiTokens.pagePadding),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: DesktopUiTokens.detailMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DesktopEntityHeaderStrip(
                title: worker.displayName,
                subtitle: isOps
                    ? UserRole.productionManager.arabicLabel
                    : UserRole.deliveryWorker.arabicLabel,
                badge: worker.isActive ? 'نشط' : 'موقوف',
                icon: isOps
                    ? Icons.precision_manufacturing_outlined
                    : Icons.local_shipping_outlined,
                metrics: [
                  DesktopEntityMetric(label: 'الهاتف', value: phone),
                  DesktopEntityMetric(label: 'البريد', value: email),
                  DesktopEntityMetric(label: 'تاريخ الإضافة', value: joined),
                ],
              ),
              const SizedBox(height: DesktopUiTokens.gapMd),
              Wrap(
                spacing: DesktopUiTokens.gapSm,
                runSpacing: DesktopUiTokens.gapSm,
                textDirection: TextDirection.rtl,
                children: [
                  AlmoutawaButton(
                    label: 'تعديل',
                    icon: Icons.edit_outlined,
                    size: AlmoutawaButtonSize.sm,
                    expanded: false,
                    onPressed: onEdit,
                  ),
                  AlmoutawaButton(
                    label: worker.isActive ? 'إيقاف' : 'تفعيل',
                    icon: worker.isActive
                        ? Icons.pause_circle_outline_rounded
                        : Icons.play_circle_outline_rounded,
                    variant: AlmoutawaButtonVariant.secondaryGlass,
                    size: AlmoutawaButtonSize.sm,
                    expanded: false,
                    onPressed: onToggleActive,
                  ),
                  AlmoutawaButton(
                    label: 'حذف',
                    icon: Icons.delete_outline_rounded,
                    variant: AlmoutawaButtonVariant.destructive,
                    size: AlmoutawaButtonSize.sm,
                    expanded: false,
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
