import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/layout/shell_scroll_insets.dart';
import '../../../../core/shared/widgets/layout/developer_credit.dart';
import '../../../../core/shared/widgets/settings/settings_group_section.dart';
import '../../../../core/shared/widgets/settings/settings_menu_row.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../routes/app_routes.dart';
import '../widgets/admin_bottom_nav_bar.dart';
import '../../../widgets/role_tab_scaffold.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/admin_settings_bloc.dart';
import '../sections/storage_usage_section.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminSettingsBloc>().add(const AdminSettingsStarted());
  }

  void _goToShellTab(AdminShellTab tab) {
    final shell = StatefulNavigationShell.maybeOf(context);
    shell?.goBranch(tab.navIndex);
  }

  void _goToProductsTab() => _goToShellTab(AdminShellTab.products);

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthBloc>().state.session;
    final displayName = session?.displayName ?? 'المدير';
    final roleLabel = session?.role.arabicLabel ?? UserRole.admin.arabicLabel;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<AdminSettingsBloc, AdminSettingsState>(
        listenWhen: (previous, current) => previous.message != current.message,
        listener: (context, state) {
          if (state.message != null) {
            AlmoutawaSnackbar.show(context, state.message!);
          }
        },
        builder: (context, state) {
          final dense = context.density.isExpanded;
          final sectionGap = dense ? DesktopUiTokens.gapMd : AppSpacing.md;

          return RoleTabScaffold(
            title: 'الإعدادات',
            subtitle: 'أهلاً، $displayName\n$roleLabel',
            contentMaxWidth: dense ? DesktopUiTokens.detailMaxWidth : null,
            body: ListView(
              padding: ShellScrollInsets.tabListPadding(context),
              children: [
                SettingsGroupSection(
                  title: 'بيانات المصنع',
                  children: [
                    SettingsMenuRow(
                      title: 'الضريبة وأرقام التواصل',
                      subtitle: 'نسبة الضريبة وأرقام الهاتف المستخدمة في المستندات',
                      icon: Icons.tune_outlined,
                      onTap: () =>
                          context.push(AppRoutes.adminCompanySettings),
                    ),
                    SettingsMenuRow(
                      title: 'المنتجات',
                      subtitle: 'تعريف المنتجات والألوان والمواصفات',
                      icon: Icons.inventory_2_outlined,
                      onTap: _goToProductsTab,
                    ),
                    SettingsMenuRow(
                      title: 'مواصفات المنتجات',
                      subtitle: 'خصائص الباب بالعربية والإنجليزية وقيمها',
                      icon: Icons.tune_outlined,
                      onTap: () =>
                          context.push(AppRoutes.adminPropertyDefinitions),
                    ),
                    SettingsMenuRow(
                      title: 'العملاء',
                      subtitle: 'بيانات العملاء وكشف الحساب',
                      icon: Icons.groups_outlined,
                      onTap: () => _goToShellTab(AdminShellTab.clients),
                    ),
                  ],
                ),
                SizedBox(height: sectionGap),
                SettingsGroupSection(
                  title: 'تشغيل المصنع',
                  children: [
                    SettingsMenuRow(
                      title: 'طلبات العمل',
                      subtitle: 'عروض الأسعار واتفاقيات العمل وملفات PDF',
                      icon: Icons.assignment_outlined,
                      onTap: () => context.push(AppRoutes.adminWorkOrders),
                    ),
                    SettingsMenuRow(
                      title: 'مندوبي التسليم',
                      subtitle: 'حسابات الدخول وصلاحيات استلام الطلبات',
                      icon: Icons.local_shipping_outlined,
                      onTap: () => _goToShellTab(AdminShellTab.workers),
                    ),
                  ],
                ),
                SizedBox(height: sectionGap),
                SettingsGroupSection(
                  title: 'الحساب والأمان',
                  children: [
                    Padding(
                      padding: EdgeInsets.all(
                        dense ? DesktopUiTokens.gapSm : AppSpacing.md,
                      ),
                      child: StorageUsageSection(
                        quota: state.storageQuota,
                        isLoading: state.isLoading,
                        onRefresh: () => context.read<AdminSettingsBloc>().add(
                          const AdminSettingsRefreshRequested(),
                        ),
                      ),
                    ),
                    SettingsMenuRow(
                      title: 'تسجيل الخروج',
                      subtitle: 'إنهاء الجلسة الحالية',
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.error,
                      titleColor: AppColors.error,
                      showChevron: false,
                      onTap: () => context.read<AuthBloc>().add(
                        const AuthSignOutRequested(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sectionGap),
                const DeveloperCredit(),
              ],
            ),
          );
        },
      ),
    );
  }
}
