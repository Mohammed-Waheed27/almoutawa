import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/feedback/empty_state_widget.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_search_field.dart';
import '../../../../core/shared/widgets/navigation/app_bar_icon_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/desktop_ui_tokens.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/property_definitions_list_bloc.dart';
import '../widgets/property_definition_list_card.dart';
import '../widgets/property_definitions_list_skeleton.dart';

class PropertyDefinitionsListPage extends StatefulWidget {
  const PropertyDefinitionsListPage({super.key});

  @override
  State<PropertyDefinitionsListPage> createState() =>
      _PropertyDefinitionsListPageState();
}

class _PropertyDefinitionsListPageState
    extends State<PropertyDefinitionsListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PropertyDefinitionsListBloc>().add(
      const PropertyDefinitionsListStarted(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({String? definitionId}) async {
    final saved = await context.push<bool?>(
      definitionId == null
          ? AppRoutes.adminPropertyDefinitionForm
          : AppRoutes.adminPropertyDefinitionEditPath(definitionId),
      extra: definitionId == null
          ? null
          : context
                .read<PropertyDefinitionsListBloc>()
                .state
                .definitions
                .where((item) => item.id == definitionId)
                .firstOrNull,
    );
    if (saved == true && mounted) {
      context.read<PropertyDefinitionsListBloc>().add(
        const PropertyDefinitionsListRefreshRequested(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RoleDashboardScaffold(
        title: 'مواصفات المنتجات',
        contentMaxWidth: context.density.isExpanded
            ? DesktopUiTokens.hubMaxWidth
            : null,
        appBarActions: [
          AppBarHeaderIconButton(
            icon: Icons.add_rounded,
            tooltip: 'خاصية جديدة',
            onPressed: () => _openForm(),
          ),
        ],
        body:
            BlocConsumer<
              PropertyDefinitionsListBloc,
              PropertyDefinitionsListState
            >(
              listenWhen: (previous, current) =>
                  previous.message != current.message,
              listener: (context, state) {
                if (state.message != null) {
                  AlmoutawaSnackbar.show(context, state.message!);
                }
              },
              builder: (context, state) {
                if (state.showBlockingSpinner) {
                  return const PropertyDefinitionsListSkeleton();
                }

                final items = state.filteredDefinitions;

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<PropertyDefinitionsListBloc>().add(
                      const PropertyDefinitionsListRefreshRequested(),
                    );
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.containerPadding,
                      AppSpacing.sm,
                      AppSpacing.containerPadding,
                      AppSpacing.sectionMargin,
                    ),
                    children: [
                      AlmoutawaSearchField(
                        controller: _searchController,
                        hint: 'بحث عن خاصية...',
                        onChanged: (query) => context
                            .read<PropertyDefinitionsListBloc>()
                            .add(PropertyDefinitionsListSearchChanged(query)),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        '${items.length} ${items.length == 1 ? 'خاصية' : 'خصائص'}',
                        style: AppTypography.labelMd().copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      if (items.isEmpty)
                        const EmptyStateWidget(
                          message: 'لا توجد خصائص — أضف أول خاصية',
                          icon: Icons.tune_outlined,
                        )
                      else
                        ...items.map(
                          (definition) => Padding(
                            padding: EdgeInsets.only(
                              bottom: AppSpacing.stackGap,
                            ),
                            child: PropertyDefinitionListCard(
                              definition: definition,
                              onTap: () =>
                                  _openForm(definitionId: definition.id),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
