import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../di/injection_container.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/orders_list_scope.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_property.dart';
import '../../domain/entities/staff_profile.dart';
import '../../domain/entities/user_role.dart';
import '../features/admin/bloc/admin_reports_bloc.dart';
import '../features/admin/bloc/admin_settings_bloc.dart';
import '../features/admin/bloc/company_settings_bloc.dart';
import '../features/admin/bloc/delivery_worker_form_bloc.dart';
import '../features/admin/bloc/delivery_workers_list_bloc.dart';
import '../features/admin/pages/admin_home_page.dart';
import '../features/admin/pages/admin_orders_page.dart';
import '../features/admin/pages/admin_reports_page.dart';
import '../features/admin/pages/admin_settings_page.dart';
import '../features/admin/pages/company_settings_page.dart';
import '../features/admin/pages/admin_shell_page.dart';
import '../features/admin/pages/admin_workers_list_page.dart';
import '../features/admin/pages/delivery_worker_form_page.dart';
import '../features/products/bloc/product_detail_bloc.dart';
import '../features/products/bloc/product_form_bloc.dart';
import '../features/products/bloc/products_list_bloc.dart';
import '../features/products/bloc/property_definition_form_bloc.dart';
import '../features/products/bloc/property_definitions_list_bloc.dart';
import '../features/products/pages/admin_products_list_page.dart';
import '../features/products/pages/product_detail_page.dart';
import '../features/products/pages/product_form_page.dart';
import '../features/products/pages/property_definition_form_page.dart';
import '../features/products/pages/property_definitions_list_page.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/pages/login_page.dart';
import '../features/bootstrap/pages/bootstrap_page.dart';
import '../features/customers/bloc/customer_detail_bloc.dart';
import '../features/customers/bloc/customer_form_bloc.dart';
import '../features/customers/bloc/customers_list_bloc.dart';
import '../features/customers/pages/customer_detail_page.dart';
import '../features/customers/pages/customer_form_page.dart';
import '../features/customers/pages/customers_list_page.dart';
import '../features/delivery/bloc/delivery_orders_bloc.dart';
import '../features/delivery/pages/delivery_home_page.dart';
import '../features/delivery/pages/delivery_order_detail_page.dart';
import '../features/delivery/pages/delivery_orders_hub_page.dart';
import '../features/delivery/pages/delivery_shell_page.dart';
import '../features/work_orders/bloc/agreement_form_bloc.dart';
import '../features/work_orders/bloc/manufacturing_card_form_bloc.dart';
import '../features/work_orders/bloc/manufacturing_cards_hub_bloc.dart';
import '../features/work_orders/bloc/quote_form_bloc.dart';
import '../features/work_orders/bloc/work_order_create_bloc.dart';
import '../features/work_orders/bloc/work_order_detail_bloc.dart';
import '../features/work_orders/bloc/work_orders_list_bloc.dart';
import '../features/work_orders/pages/agreement_form_page.dart';
import '../features/work_orders/pages/agreement_view_page.dart';
import '../features/work_orders/pages/manufacturing_card_form_page.dart';
import '../features/work_orders/pages/manufacturing_cards_hub_page.dart';
import '../features/work_orders/pages/quote_form_page.dart';
import '../features/work_orders/pages/quote_view_page.dart';
import '../features/work_orders/pages/work_order_create_page.dart';
import '../features/work_orders/pages/work_order_customer_picker_page.dart';
import '../features/work_orders/pages/work_order_detail_page.dart';
import '../features/work_orders/pages/work_order_product_picker_page.dart';
import '../features/work_orders/pages/work_orders_list_page.dart';
import '../features/production/pages/production_home_page.dart';
import '../features/production/pages/production_orders_hub_page.dart';
import '../features/production/pages/production_shell_page.dart';
import '../features/sales/pages/sales_dashboard_page.dart';
import 'app_routes.dart';
import 'auth_refresh_notifier.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createAppRouter({
  required AuthBloc authBloc,
  required AuthRefreshNotifier refreshNotifier,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.login,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoading =
          authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLogin = state.matchedLocation == AppRoutes.login;
      final isBootstrap = state.matchedLocation == AppRoutes.bootstrap;

      if (isLoading) {
        return null;
      }

      if (!isAuthenticated) {
        if (isLogin || (kDebugMode && isBootstrap)) {
          return null;
        }
        return AppRoutes.login;
      }

      final session = authState.session!;
      final home = AppRoutes.homeForRole(session.role);

      if (isLogin || state.matchedLocation == '/') {
        return home;
      }

      final requiredRole = AppRoutes.roleForPath(state.matchedLocation);
      if (requiredRole != null && requiredRole != session.role) {
        return home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.bootstrap,
          builder: (context, state) => const BootstrapPage(),
        ),
      GoRoute(
        path: AppRoutes.salesDashboard,
        builder: (context, state) => const SalesDashboardPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    getIt<WorkOrdersListBloc>()
                      ..add(const WorkOrdersListStarted()),
              ),
            ],
            child: ProductionShellPage(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.productionDashboard,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProductionHomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.productionOrders,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProductionOrdersHubPage()),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) =>
                    getIt<WorkOrdersListBloc>()
                      ..add(const WorkOrdersListStarted()),
              ),
              BlocProvider(
                create: (_) =>
                    getIt<ProductsListBloc>()..add(const ProductsListStarted()),
              ),
              BlocProvider(
                create: (_) =>
                    getIt<AdminSettingsBloc>()
                      ..add(const AdminSettingsStarted()),
              ),
            ],
            child: AdminShellPage(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminCustomers,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: BlocProvider(
                    create: (_) =>
                        getIt<CustomersListBloc>()
                          ..add(const CustomersListStarted()),
                    child: const CustomersListPage(rolePrefix: 'admin'),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => BlocProvider(
                      create: (_) => getIt<CustomerFormBloc>(),
                      child: const CustomerFormPage(),
                    ),
                  ),
                  GoRoute(
                    path: ':customerId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final customerId = state.pathParameters['customerId']!;
                      return BlocProvider(
                        create: (_) =>
                            getIt<CustomerDetailBloc>()
                              ..add(CustomerDetailStarted(customerId)),
                        child: CustomerDetailPage(
                          customerId: customerId,
                          rolePrefix: 'admin',
                        ),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) {
                          final existing = state.extra as Customer?;
                          return BlocProvider(
                            create: (_) =>
                                getIt<CustomerFormBloc>(param1: existing),
                            child: CustomerFormPage(existing: existing),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminWorkers,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AdminWorkersListPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminHome,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AdminHomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminDashboard,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AdminProductsListPage()),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => BlocProvider(
                      create: (_) => getIt<ProductFormBloc>(param1: null),
                      child: const ProductFormPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.adminSettings,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AdminSettingsPage()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.adminOrders,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<DeliveryOrdersBloc>(param1: OrdersListScope.adminAll)
                ..add(const DeliveryOrdersStarted()),
          child: const AdminOrdersPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<AdminReportsBloc>()..add(const AdminReportsStarted()),
          child: const AdminReportsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminWorkerForm,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final role = state.extra is UserRole
              ? state.extra as UserRole
              : UserRole.deliveryWorker;
          return BlocProvider(
            create: (_) =>
                getIt<DeliveryWorkerFormBloc>(param1: null, param2: role),
            child: DeliveryWorkerFormPage(staffRole: role),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminCompanySettings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<CompanySettingsBloc>()..add(const CompanySettingsStarted()),
          child: const CompanySettingsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminPropertyDefinitions,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<PropertyDefinitionsListBloc>(),
          child: const PropertyDefinitionsListPage(),
        ),
        routes: [
          GoRoute(
            path: 'new',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => BlocProvider(
              create: (_) => getIt<PropertyDefinitionFormBloc>(),
              child: const PropertyDefinitionFormPage(),
            ),
          ),
          GoRoute(
            path: ':definitionId/edit',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final existing = state.extra as ProductPropertyDefinition?;
              return BlocProvider(
                create: (_) =>
                    getIt<PropertyDefinitionFormBloc>(param1: existing),
                child: PropertyDefinitionFormPage(existing: existing),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/admin/workers/:profileId/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final existing = state.extra as StaffProfile?;
          final role = existing?.role ?? UserRole.deliveryWorker;
          return BlocProvider(
            create: (_) =>
                getIt<DeliveryWorkerFormBloc>(param1: existing, param2: role),
            child: DeliveryWorkerFormPage(existing: existing, staffRole: role),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminOrderDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return BlocProvider(
            create: (_) =>
                getIt<DeliveryOrdersBloc>(param1: OrdersListScope.adminAll)
                  ..add(const DeliveryOrdersStarted()),
            child: DeliveryOrderDetailPage(orderId: orderId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.adminProductDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          final initialProduct = state.extra as Product?;
          return BlocProvider(
            create: (_) => getIt<ProductDetailBloc>()
              ..add(
                ProductDetailStarted(productId, initialProduct: initialProduct),
              ),
            child: ProductDetailPage(productId: productId),
          );
        },
      ),
      GoRoute(
        path: '/admin/product/:productId/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final existing = state.extra as Product?;
          return BlocProvider(
            create: (_) => getIt<ProductFormBloc>(param1: existing),
            child: ProductFormPage(existing: existing),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => getIt<DeliveryOrdersBloc>(
                  param1: OrdersListScope.deliveryWorker,
                )..add(const DeliveryOrdersStarted()),
              ),
              BlocProvider(
                create: (_) =>
                    getIt<WorkOrdersListBloc>()
                      ..add(const WorkOrdersListStarted()),
              ),
            ],
            child: DeliveryShellPage(navigationShell: navigationShell),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.deliveryDashboard,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DeliveryHomePage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.deliveryCustomers,
                pageBuilder: (context, state) => NoTransitionPage(
                  child: BlocProvider(
                    create: (_) =>
                        getIt<CustomersListBloc>()
                          ..add(const CustomersListStarted()),
                    child: const CustomersListPage(rolePrefix: 'delivery'),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) => BlocProvider(
                      create: (_) => getIt<CustomerFormBloc>(),
                      child: const CustomerFormPage(),
                    ),
                  ),
                  GoRoute(
                    path: ':customerId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final customerId = state.pathParameters['customerId']!;
                      return BlocProvider(
                        create: (_) =>
                            getIt<CustomerDetailBloc>()
                              ..add(CustomerDetailStarted(customerId)),
                        child: CustomerDetailPage(
                          customerId: customerId,
                          rolePrefix: 'delivery',
                        ),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (context, state) {
                          final existing = state.extra as Customer?;
                          return BlocProvider(
                            create: (_) =>
                                getIt<CustomerFormBloc>(param1: existing),
                            child: CustomerFormPage(existing: existing),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.deliveryOrders,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DeliveryOrdersHubPage()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.deliveryOrderDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return BlocProvider(
            create: (_) => getIt<DeliveryOrdersBloc>(
              param1: OrdersListScope.deliveryWorker,
            )..add(const DeliveryOrdersStarted()),
            child: DeliveryOrderDetailPage(orderId: orderId),
          );
        },
      ),

      GoRoute(
        path: '/delivery/work-orders/new',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<WorkOrderCreateBloc>()
                ..add(const WorkOrderCreateStarted(requireFactory: false)),
          child: const WorkOrderCreatePage(rolePrefix: 'delivery'),
        ),
        routes: [
          GoRoute(
            path: 'pick-customer',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => BlocProvider(
              create: (_) =>
                  getIt<CustomersListBloc>()..add(const CustomersListStarted()),
              child: const WorkOrderCustomerPickerPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/delivery/work-orders/pick-product',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<ProductsListBloc>()..add(const ProductsListStarted()),
          child: const WorkOrderProductPickerPage(rolePrefix: 'delivery'),
        ),
      ),
      GoRoute(
        path: '/delivery/work-orders/product/:productId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          final initialProduct = state.extra is Product
              ? state.extra as Product
              : null;
          return BlocProvider(
            create: (_) => getIt<ProductDetailBloc>()
              ..add(
                ProductDetailStarted(productId, initialProduct: initialProduct),
              ),
            child: ProductDetailPage(productId: productId, readOnly: true),
          );
        },
      ),
      GoRoute(
        path: '/delivery/work-orders/:orderId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return BlocProvider(
            create: (_) =>
                getIt<WorkOrderDetailBloc>()
                  ..add(WorkOrderDetailStarted(orderId)),
            child: WorkOrderDetailPage(
              rolePrefix: 'delivery',
              orderId: orderId,
            ),
          );
        },
        routes: [
          GoRoute(
            path: 'quote',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<QuoteFormBloc>()..add(QuoteFormStarted(orderId)),
                child: QuoteFormPage(orderId: orderId, rolePrefix: 'delivery'),
              );
            },
          ),
          GoRoute(
            path: 'quote-view',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<WorkOrderDetailBloc>()
                      ..add(WorkOrderDetailStarted(orderId)),
                child: QuoteViewPage(rolePrefix: 'delivery', orderId: orderId),
              );
            },
          ),
          GoRoute(
            path: 'agreement',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<AgreementFormBloc>()
                      ..add(AgreementFormStarted(orderId)),
                child: AgreementFormPage(
                  orderId: orderId,
                  rolePrefix: 'delivery',
                ),
              );
            },
          ),
          GoRoute(
            path: 'agreement-view',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<WorkOrderDetailBloc>()
                      ..add(WorkOrderDetailStarted(orderId)),
                child: AgreementViewPage(
                  rolePrefix: 'delivery',
                  orderId: orderId,
                ),
              );
            },
          ),
          GoRoute(
            path: 'manufacturing',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<ManufacturingCardsHubBloc>()
                      ..add(ManufacturingCardsHubStarted(orderId)),
                child: ManufacturingCardsHubPage(
                  rolePrefix: 'delivery',
                  orderId: orderId,
                ),
              );
            },
            routes: [
              GoRoute(
                path: 'line/:lineId/card/:cardIndex',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final orderId = state.pathParameters['orderId']!;
                  final lineId = state.pathParameters['lineId']!;
                  final cardIndex =
                      int.tryParse(state.pathParameters['cardIndex']!) ?? 1;
                  return BlocProvider(
                    create: (_) => getIt<ManufacturingCardFormBloc>()
                      ..add(
                        ManufacturingCardFormStarted(
                          orderId: orderId,
                          agreementLineId: lineId,
                          cardIndex: cardIndex,
                        ),
                      ),
                    child: ManufacturingCardFormPage(
                      rolePrefix: 'delivery',
                      orderId: orderId,
                      agreementLineId: lineId,
                      cardIndex: cardIndex,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/production/work-orders/pick-product',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<ProductsListBloc>()..add(const ProductsListStarted()),
          child: const WorkOrderProductPickerPage(rolePrefix: 'production'),
        ),
      ),
      GoRoute(
        path: '/production/work-orders/product/:productId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          final initialProduct = state.extra is Product
              ? state.extra as Product
              : null;
          return BlocProvider(
            create: (_) => getIt<ProductDetailBloc>()
              ..add(
                ProductDetailStarted(productId, initialProduct: initialProduct),
              ),
            child: ProductDetailPage(productId: productId, readOnly: true),
          );
        },
      ),
      GoRoute(
        path: '/production/work-orders/:orderId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return BlocProvider(
            create: (_) =>
                getIt<WorkOrderDetailBloc>()
                  ..add(WorkOrderDetailStarted(orderId, loadOpsControls: true)),
            child: WorkOrderDetailPage(
              rolePrefix: 'production',
              orderId: orderId,
            ),
          );
        },
        routes: [
          GoRoute(
            path: 'quote',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<QuoteFormBloc>()..add(QuoteFormStarted(orderId)),
                child: QuoteFormPage(
                  orderId: orderId,
                  rolePrefix: 'production',
                ),
              );
            },
          ),
          GoRoute(
            path: 'quote-view',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) => getIt<WorkOrderDetailBloc>()
                  ..add(WorkOrderDetailStarted(orderId, loadOpsControls: true)),
                child: QuoteViewPage(
                  rolePrefix: 'production',
                  orderId: orderId,
                ),
              );
            },
          ),
          GoRoute(
            path: 'agreement',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<AgreementFormBloc>()
                      ..add(AgreementFormStarted(orderId)),
                child: AgreementFormPage(
                  orderId: orderId,
                  rolePrefix: 'production',
                ),
              );
            },
          ),
          GoRoute(
            path: 'agreement-view',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) => getIt<WorkOrderDetailBloc>()
                  ..add(WorkOrderDetailStarted(orderId, loadOpsControls: true)),
                child: AgreementViewPage(
                  rolePrefix: 'production',
                  orderId: orderId,
                ),
              );
            },
          ),
          GoRoute(
            path: 'manufacturing',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<ManufacturingCardsHubBloc>()
                      ..add(ManufacturingCardsHubStarted(orderId)),
                child: ManufacturingCardsHubPage(
                  rolePrefix: 'production',
                  orderId: orderId,
                ),
              );
            },
            routes: [
              GoRoute(
                path: 'line/:lineId/card/:cardIndex',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final orderId = state.pathParameters['orderId']!;
                  final lineId = state.pathParameters['lineId']!;
                  final cardIndex =
                      int.tryParse(state.pathParameters['cardIndex']!) ?? 1;
                  return BlocProvider(
                    create: (_) => getIt<ManufacturingCardFormBloc>()
                      ..add(
                        ManufacturingCardFormStarted(
                          orderId: orderId,
                          agreementLineId: lineId,
                          cardIndex: cardIndex,
                        ),
                      ),
                    child: ManufacturingCardFormPage(
                      rolePrefix: 'production',
                      orderId: orderId,
                      agreementLineId: lineId,
                      cardIndex: cardIndex,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.adminWorkOrders,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<WorkOrdersListBloc>()..add(const WorkOrdersListStarted()),
          child: const WorkOrdersListPage(rolePrefix: 'admin'),
        ),
      ),
      GoRoute(
        path: '/admin/work-orders/new',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<WorkOrderCreateBloc>()..add(const WorkOrderCreateStarted()),
          child: const WorkOrderCreatePage(rolePrefix: 'admin'),
        ),
        routes: [
          GoRoute(
            path: 'pick-customer',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => BlocProvider(
              create: (_) =>
                  getIt<CustomersListBloc>()..add(const CustomersListStarted()),
              child: const WorkOrderCustomerPickerPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/admin/work-orders/pick-product',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<ProductsListBloc>()..add(const ProductsListStarted()),
          child: const WorkOrderProductPickerPage(rolePrefix: 'admin'),
        ),
      ),
      GoRoute(
        path: '/admin/work-orders/product/:productId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final productId = state.pathParameters['productId']!;
          final initialProduct = state.extra is Product
              ? state.extra as Product
              : null;
          return BlocProvider(
            create: (_) => getIt<ProductDetailBloc>()
              ..add(
                ProductDetailStarted(productId, initialProduct: initialProduct),
              ),
            child: ProductDetailPage(productId: productId, readOnly: true),
          );
        },
      ),
      GoRoute(
        path: '/admin/work-orders/:orderId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return BlocProvider(
            create: (_) =>
                getIt<WorkOrderDetailBloc>()
                  ..add(WorkOrderDetailStarted(orderId, loadOpsControls: true)),
            child: WorkOrderDetailPage(rolePrefix: 'admin', orderId: orderId),
          );
        },
        routes: [
          GoRoute(
            path: 'quote',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<QuoteFormBloc>()..add(QuoteFormStarted(orderId)),
                child: QuoteFormPage(orderId: orderId, rolePrefix: 'admin'),
              );
            },
          ),
          GoRoute(
            path: 'quote-view',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<WorkOrderDetailBloc>()
                      ..add(WorkOrderDetailStarted(orderId)),
                child: QuoteViewPage(rolePrefix: 'admin', orderId: orderId),
              );
            },
          ),
          GoRoute(
            path: 'agreement',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<AgreementFormBloc>()
                      ..add(AgreementFormStarted(orderId)),
                child: AgreementFormPage(orderId: orderId, rolePrefix: 'admin'),
              );
            },
          ),
          GoRoute(
            path: 'agreement-view',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<WorkOrderDetailBloc>()
                      ..add(WorkOrderDetailStarted(orderId)),
                child: AgreementViewPage(rolePrefix: 'admin', orderId: orderId),
              );
            },
          ),
          GoRoute(
            path: 'manufacturing',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId']!;
              return BlocProvider(
                create: (_) =>
                    getIt<ManufacturingCardsHubBloc>()
                      ..add(ManufacturingCardsHubStarted(orderId)),
                child: ManufacturingCardsHubPage(
                  rolePrefix: 'admin',
                  orderId: orderId,
                ),
              );
            },
            routes: [
              GoRoute(
                path: 'line/:lineId/card/:cardIndex',
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final orderId = state.pathParameters['orderId']!;
                  final lineId = state.pathParameters['lineId']!;
                  final cardIndex =
                      int.tryParse(state.pathParameters['cardIndex']!) ?? 1;
                  return BlocProvider(
                    create: (_) => getIt<ManufacturingCardFormBloc>()
                      ..add(
                        ManufacturingCardFormStarted(
                          orderId: orderId,
                          agreementLineId: lineId,
                          cardIndex: cardIndex,
                        ),
                      ),
                    child: ManufacturingCardFormPage(
                      rolePrefix: 'admin',
                      orderId: orderId,
                      agreementLineId: lineId,
                      cardIndex: cardIndex,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
