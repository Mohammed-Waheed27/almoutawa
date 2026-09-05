import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/bloc/skeleton_refresh.dart';
import '../../../../core/shared/widgets/navigation/hub_gradient_app_bar.dart';
import '../../../../core/shared/widgets/navigation/segmented_tab_bar.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../di/injection_container.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_tab_scaffold.dart';
import '../bloc/delivery_workers_list_bloc.dart';
import '../widgets/admin_staff_role_list_pane.dart';

/// Admin staff hub — delivery workers + ops managers with smooth tab swipe.
///
/// Each role keeps its own [DeliveryWorkersListBloc] so switching tabs never
/// clears/reloads the other list.
class AdminWorkersListPage extends StatefulWidget {
  const AdminWorkersListPage({super.key});

  @override
  State<AdminWorkersListPage> createState() => _AdminWorkersListPageState();
}

class _AdminWorkersListPageState extends State<AdminWorkersListPage>
    with SingleTickerProviderStateMixin {
  static const _tabs = ['مندوبو التسليم', 'مديرو التشغيل'];

  late final TabController _tabController;
  late final DeliveryWorkersListBloc _deliveryBloc;
  late final DeliveryWorkersListBloc _opsBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabControllerTick);

    _deliveryBloc = getIt<DeliveryWorkersListBloc>()
      ..add(const DeliveryWorkersListStarted(role: UserRole.deliveryWorker));
    _opsBloc = getIt<DeliveryWorkersListBloc>()
      ..add(const DeliveryWorkersListStarted(role: UserRole.productionManager));
  }

  void _onTabControllerTick() {
    if (!mounted) return;
    // Rebuild app-bar actions when the settled index changes (not every frame).
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabControllerTick)
      ..dispose();
    _deliveryBloc.close();
    _opsBloc.close();
    super.dispose();
  }

  UserRole get _activeRole => _tabController.index == 1
      ? UserRole.productionManager
      : UserRole.deliveryWorker;

  DeliveryWorkersListBloc get _activeBloc =>
      _tabController.index == 1 ? _opsBloc : _deliveryBloc;

  bool get _isOps => _activeRole == UserRole.productionManager;

  Future<void> _openWorkerForm({String? editPath, Object? extra}) async {
    final saved = await context.push<bool?>(
      editPath ?? AppRoutes.adminWorkerForm,
      extra: extra ?? _activeRole,
    );
    if (saved == true && mounted) {
      _activeBloc.add(const DeliveryWorkersListRefreshRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final dense = context.density.isExpanded;
    final tabPad = dense
        ? DesktopUiTokens.pagePadding
        : AppSpacing.containerPadding;
    final tabGap = dense ? DesktopUiTokens.gapSm : AppSpacing.md;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: RoleTabScaffold(
        title: 'الموظفون',
        // Master–detail needs full width — do not hubMaxWidth-constrain.
        constrainBody: !dense,
        actions: [
          HubHeaderIconButton(
            icon: Icons.person_add_outlined,
            tooltip: _isOps ? 'مدير تشغيل جديد' : 'مندوب جديد',
            onPressed: () => _openWorkerForm(extra: _activeRole),
          ),
          HubHeaderIconButton(
            icon: Icons.refresh_rounded,
            tooltip: 'تحديث',
            onPressed: () => _activeBloc.add(
              const DeliveryWorkersListRefreshRequested(
                showSkeleton: SkeletonRefresh.showSkeleton,
              ),
            ),
          ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                tabPad,
                dense ? DesktopUiTokens.gapSm : AppSpacing.sm,
                tabPad,
                0,
              ),
              child: AnimatedBuilder(
                animation: _tabController.animation!,
                builder: (context, _) {
                  final selected = _tabController.animation!.value
                      .round()
                      .clamp(0, _tabs.length - 1);
                  return SegmentedTabBar(
                    tabs: _tabs,
                    selectedIndex: selected,
                    controller: _tabController,
                    onSelected: (index) {
                      if (index == _tabController.index) return;
                      _tabController.animateTo(index);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: tabGap),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  BlocProvider.value(
                    value: _deliveryBloc,
                    child: AdminStaffRoleListPane(
                      role: UserRole.deliveryWorker,
                      onOpenForm: _openWorkerForm,
                    ),
                  ),
                  BlocProvider.value(
                    value: _opsBloc,
                    child: AdminStaffRoleListPane(
                      role: UserRole.productionManager,
                      onOpenForm: _openWorkerForm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
