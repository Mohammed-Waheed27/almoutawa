import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../../domain/entities/customer.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/work_order_create_bloc.dart';
import '../sections/work_order_factory_picker_section.dart';
import '../sections/work_order_selected_customer_section.dart';
import '../widgets/work_order_create_skeleton.dart';

class WorkOrderCreatePage extends StatefulWidget {
  const WorkOrderCreatePage({super.key, required this.rolePrefix});

  final String rolePrefix;

  @override
  State<WorkOrderCreatePage> createState() => _WorkOrderCreatePageState();
}

class _WorkOrderCreatePageState extends State<WorkOrderCreatePage> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _openCustomerPicker(BuildContext context) async {
    final selected = await context.push<Customer>(
      AppRoutes.workOrderCustomerPickPath(widget.rolePrefix),
    );
    if (selected == null || !context.mounted) return;
    context.read<WorkOrderCreateBloc>().add(
      WorkOrderCreateCustomerSelected(selected),
    );
  }

  Future<void> _handleBack() async {
    final state = context.read<WorkOrderCreateBloc>().state;
    final hasSelection =
        state.selectedCustomer != null || (state.notes ?? '').trim().isNotEmpty;
    if (hasSelection) {
      final leave = await showDialog<bool>(
        context: context,
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('مغادرة الطلب الجديد؟'),
            content: const Text('لم يتم إنشاء الطلب بعد. هل تريد المغادرة؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('البقاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('مغادرة'),
              ),
            ],
          ),
        ),
      );
      if (leave != true || !mounted) return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(
        widget.rolePrefix == 'admin'
            ? AppRoutes.adminWorkOrders
            : AppRoutes.deliveryOrders,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack();
      },
      child: RoleDashboardScaffold(
        title: 'طلب عمل جديد',
        showBackButton: true,
        onBack: _handleBack,
        contentMaxWidth: DesktopUiTokens.formMaxWidth,
        body: BlocConsumer<WorkOrderCreateBloc, WorkOrderCreateState>(
          listenWhen: (p, c) =>
              p.status != c.status ||
              (p.message != c.message && c.message != null),
          listener: (context, state) {
            if (state.message != null &&
                state.status != WorkOrderCreateStatus.success) {
              AlmoutawaSnackbar.show(context, state.message!);
            }
            if (state.status == WorkOrderCreateStatus.success &&
                state.createdDetail != null) {
              AlmoutawaSnackbar.show(context, 'تم إنشاء الطلب');
              context.go(
                AppRoutes.workOrderQuotePath(
                  widget.rolePrefix,
                  state.createdDetail!.order.id,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.showBlockingSkeleton) {
              return const WorkOrderCreateSkeleton();
            }

            if (state.status == WorkOrderCreateStatus.failure &&
                state.factories.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.containerPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message ?? 'تعذّر تحميل البيانات',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.md),
                      AlmoutawaButton(
                        label: 'إعادة المحاولة',
                        onPressed: () => context
                            .read<WorkOrderCreateBloc>()
                            .add(const WorkOrderCreateStarted()),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.containerPadding,
                AppSpacing.sm,
                AppSpacing.containerPadding,
                AppSpacing.xl,
              ),
              children: [
                if (state.requireFactory) ...[
                  WorkOrderFactoryPickerSection(
                    factories: state.factories,
                    selectedFactoryId: state.selectedFactoryId,
                    onSelected: (id) => context.read<WorkOrderCreateBloc>().add(
                      WorkOrderCreateFactorySelected(id),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                ],
                WorkOrderSelectedCustomerSection(
                  customer: state.selectedCustomer,
                  onSelect: () => _openCustomerPicker(context),
                ),
                SizedBox(height: AppSpacing.md),
                AlmoutawaTextField(
                  controller: _notesController,
                  label: 'ملاحظات (اختياري)',
                  hint: 'أي ملاحظات داخلية على الطلب...',
                  maxLines: 3,
                ),
                SizedBox(height: AppSpacing.lg),
                AlmoutawaButton(
                  label: state.status == WorkOrderCreateStatus.submitting
                      ? 'جاري الإنشاء...'
                      : 'متابعة إلى عرض السعر',
                  onPressed: state.status == WorkOrderCreateStatus.submitting
                      ? null
                      : () {
                          final bloc = context.read<WorkOrderCreateBloc>();
                          bloc.add(
                            WorkOrderCreateNotesChanged(_notesController.text),
                          );
                          bloc.add(const WorkOrderCreateSubmitted());
                        },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
