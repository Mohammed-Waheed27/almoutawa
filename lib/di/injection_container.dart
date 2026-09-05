import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/pdf/agreement_pdf_builder.dart';
import '../core/pdf/manufacturing_card_pdf_builder.dart';
import '../core/pdf/pdf_share_service.dart';
import '../core/pdf/quote_pdf_builder.dart';
import '../core/storage/session_cache.dart';
import '../data/datasources/admin_reports_remote_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/commercial_orders_remote_data_source.dart';
import '../data/datasources/company_settings_remote_data_source.dart';
import '../data/datasources/customers_remote_data_source.dart';
import '../data/datasources/delivery_orders_remote_data_source.dart';
import '../data/datasources/product_media_storage_data_source.dart';
import '../data/datasources/product_properties_remote_data_source.dart';
import '../data/datasources/products_remote_data_source.dart';
import '../data/datasources/staff_remote_data_source.dart';
import '../data/datasources/storage_settings_remote_data_source.dart';
import '../data/repositories/admin_reports_repository_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/commercial_order_repository_impl.dart';
import '../data/repositories/company_settings_repository_impl.dart';
import '../data/repositories/customer_repository_impl.dart';
import '../data/repositories/delivery_repository_impl.dart';
import '../data/repositories/product_property_repository_impl.dart';
import '../data/repositories/product_repository_impl.dart';
import '../data/repositories/staff_repository_impl.dart';
import '../data/repositories/storage_repository_impl.dart';
import '../domain/entities/customer.dart';
import '../domain/entities/orders_list_scope.dart';
import '../domain/entities/product.dart';
import '../domain/entities/product_property.dart';
import '../domain/entities/staff_profile.dart';
import '../domain/entities/user_role.dart';
import '../domain/repositories/admin_reports_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/commercial_order_repository.dart';
import '../domain/repositories/company_settings_repository.dart';
import '../domain/repositories/customer_repository.dart';
import '../domain/repositories/delivery_repository.dart';
import '../domain/repositories/product_property_repository.dart';
import '../domain/repositories/product_repository.dart';
import '../domain/repositories/staff_repository.dart';
import '../domain/repositories/storage_repository.dart';
import '../domain/usecases/admin_reports_usecases.dart';
import '../domain/usecases/auth_usecases.dart';
import '../domain/usecases/commercial_order_usecases.dart';
import '../domain/usecases/company_settings_usecases.dart';
import '../domain/usecases/customer_usecases.dart';
import '../domain/usecases/delivery_usecases.dart';
import '../domain/usecases/product_property_usecases.dart';
import '../domain/usecases/product_usecases.dart';
import '../domain/usecases/staff_usecases.dart';
import '../domain/usecases/storage_usecases.dart';
import '../presentation/features/admin/bloc/admin_reports_bloc.dart';
import '../presentation/features/admin/bloc/company_settings_bloc.dart';
import '../presentation/features/admin/bloc/admin_settings_bloc.dart';
import '../presentation/features/admin/bloc/delivery_worker_form_bloc.dart';
import '../presentation/features/admin/bloc/delivery_workers_list_bloc.dart';
import '../presentation/features/products/bloc/product_detail_bloc.dart';
import '../presentation/features/products/bloc/product_form_bloc.dart';
import '../presentation/features/products/bloc/products_list_bloc.dart';
import '../presentation/features/products/bloc/property_definition_form_bloc.dart';
import '../presentation/features/products/bloc/property_definitions_list_bloc.dart';
import '../presentation/features/auth/bloc/auth_bloc.dart';
import '../presentation/features/customers/bloc/customer_detail_bloc.dart';
import '../presentation/features/customers/bloc/customer_form_bloc.dart';
import '../presentation/features/customers/bloc/customers_list_bloc.dart';
import '../presentation/features/delivery/bloc/delivery_orders_bloc.dart';
import '../presentation/features/work_orders/bloc/agreement_form_bloc.dart';
import '../presentation/features/work_orders/bloc/manufacturing_card_form_bloc.dart';
import '../presentation/features/work_orders/bloc/manufacturing_cards_hub_bloc.dart';
import '../presentation/features/work_orders/bloc/quote_form_bloc.dart';
import '../presentation/features/work_orders/bloc/work_order_create_bloc.dart';
import '../presentation/features/work_orders/bloc/work_order_detail_bloc.dart';
import '../presentation/features/work_orders/bloc/work_orders_list_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (getIt.isRegistered<FlutterSecureStorage>()) {
    return;
  }

  const secureStorage = FlutterSecureStorage();
  getIt.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);
  getIt.registerLazySingleton<SessionCache>(
    () => SessionCache(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<DeliveryOrdersRemoteDataSource>(
    () => DeliveryOrdersRemoteDataSource(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<CustomersRemoteDataSource>(
    () => CustomersRemoteDataSource(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<CommercialOrdersRemoteDataSource>(
    () => CommercialOrdersRemoteDataSource(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<CompanySettingsRemoteDataSource>(
    () => CompanySettingsRemoteDataSource(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<ProductMediaStorageDataSource>(
    () => ProductMediaStorageDataSource(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<ProductPropertiesRemoteDataSource>(
    () => ProductPropertiesRemoteDataSource(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSource(
      getIt<SupabaseClient>(),
      getIt<ProductMediaStorageDataSource>(),
      getIt<ProductPropertiesRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<StorageSettingsRemoteDataSource>(
    () => StorageSettingsRemoteDataSource(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<StaffRemoteDataSource>(
    () => StaffRemoteDataSource(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<AdminReportsRemoteDataSource>(
    () => AdminReportsRemoteDataSource(getIt<SupabaseClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: getIt<AuthRemoteDataSource>(),
      sessionCache: getIt<SessionCache>(),
    ),
  );
  getIt.registerLazySingleton<DeliveryRepository>(
    () => DeliveryRepositoryImpl(getIt<DeliveryOrdersRemoteDataSource>()),
  );
  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(getIt<CustomersRemoteDataSource>()),
  );
  getIt.registerLazySingleton<CommercialOrderRepository>(
    () => CommercialOrderRepositoryImpl(
      getIt<CommercialOrdersRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<CompanySettingsRepository>(
    () => CompanySettingsRepositoryImpl(
      getIt<CompanySettingsRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      getIt<ProductsRemoteDataSource>(),
      getIt<StorageSettingsRemoteDataSource>(),
      getIt<ProductMediaStorageDataSource>(),
    ),
  );
  getIt.registerLazySingleton<ProductPropertyRepository>(
    () => ProductPropertyRepositoryImpl(
      getIt<ProductPropertiesRemoteDataSource>(),
    ),
  );
  getIt.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(getIt<StorageSettingsRemoteDataSource>()),
  );
  getIt.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(getIt<StaffRemoteDataSource>()),
  );
  getIt.registerLazySingleton<AdminReportsRepository>(
    () => AdminReportsRepositoryImpl(getIt<AdminReportsRemoteDataSource>()),
  );

  getIt.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<RestoreSessionUseCase>(
    () => RestoreSessionUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<FetchOrdersPageUseCase>(
    () => FetchOrdersPageUseCase(getIt<DeliveryRepository>()),
  );
  getIt.registerLazySingleton<MarkOrderDeliveredUseCase>(
    () => MarkOrderDeliveredUseCase(getIt<DeliveryRepository>()),
  );
  getIt.registerLazySingleton<FetchCustomersPageUseCase>(
    () => FetchCustomersPageUseCase(getIt<CustomerRepository>()),
  );
  getIt.registerLazySingleton<FetchCustomerDetailUseCase>(
    () => FetchCustomerDetailUseCase(getIt<CustomerRepository>()),
  );
  getIt.registerLazySingleton<CreateCustomerUseCase>(
    () => CreateCustomerUseCase(getIt<CustomerRepository>()),
  );
  getIt.registerLazySingleton<UpdateCustomerUseCase>(
    () => UpdateCustomerUseCase(getIt<CustomerRepository>()),
  );
  getIt.registerLazySingleton<FetchFactoriesUseCase>(
    () => FetchFactoriesUseCase(getIt<CommercialOrderRepository>()),
  );
  getIt.registerLazySingleton<FetchCommercialOrdersPageUseCase>(
    () => FetchCommercialOrdersPageUseCase(getIt<CommercialOrderRepository>()),
  );
  getIt.registerLazySingleton<FetchCommercialOrdersForCustomerUseCase>(
    () => FetchCommercialOrdersForCustomerUseCase(
      getIt<CommercialOrderRepository>(),
    ),
  );
  getIt.registerLazySingleton<FetchCommercialOrderDetailUseCase>(
    () => FetchCommercialOrderDetailUseCase(getIt<CommercialOrderRepository>()),
  );
  getIt.registerLazySingleton<CreateCommercialOrderUseCase>(
    () => CreateCommercialOrderUseCase(getIt<CommercialOrderRepository>()),
  );
  getIt.registerLazySingleton<SaveQuoteUseCase>(
    () => SaveQuoteUseCase(getIt<CommercialOrderRepository>()),
  );
  getIt.registerLazySingleton<SaveAgreementUseCase>(
    () => SaveAgreementUseCase(getIt<CommercialOrderRepository>()),
  );
  getIt.registerLazySingleton<FetchManufacturingCardsUseCase>(
    () => FetchManufacturingCardsUseCase(getIt<CommercialOrderRepository>()),
  );
  getIt.registerLazySingleton<SaveManufacturingCardUseCase>(
    () => SaveManufacturingCardUseCase(getIt<CommercialOrderRepository>()),
  );
  getIt.registerLazySingleton<AdvanceCommercialOrderPhaseUseCase>(
    () =>
        AdvanceCommercialOrderPhaseUseCase(getIt<CommercialOrderRepository>()),
  );
  getIt.registerLazySingleton<AssignCommercialOrderFactoryUseCase>(
    () =>
        AssignCommercialOrderFactoryUseCase(getIt<CommercialOrderRepository>()),
  );
  getIt.registerLazySingleton<DefaultQuoteOtherCommentsUseCase>(
    () => DefaultQuoteOtherCommentsUseCase(getIt<CommercialOrderRepository>()),
  );
  getIt.registerLazySingleton<FetchProductsPageUseCase>(
    () => FetchProductsPageUseCase(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton<FetchProductDetailUseCase>(
    () => FetchProductDetailUseCase(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton<CreateProductUseCase>(
    () => CreateProductUseCase(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton<UpdateProductUseCase>(
    () => UpdateProductUseCase(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton<AppendProductImageUseCase>(
    () => AppendProductImageUseCase(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton<AppendColorImageUseCase>(
    () => AppendColorImageUseCase(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton<UploadPublicMediaUseCase>(
    () => UploadPublicMediaUseCase(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton<FetchProductPropertyDefinitionsUseCase>(
    () => FetchProductPropertyDefinitionsUseCase(
      getIt<ProductPropertyRepository>(),
    ),
  );
  getIt.registerLazySingleton<SaveProductPropertyDefinitionUseCase>(
    () => SaveProductPropertyDefinitionUseCase(
      getIt<ProductPropertyRepository>(),
    ),
  );
  getIt.registerLazySingleton<FetchStorageQuotaUseCase>(
    () => FetchStorageQuotaUseCase(getIt<StorageRepository>()),
  );
  getIt.registerLazySingleton<FetchAdminReportsUseCase>(
    () => FetchAdminReportsUseCase(getIt<AdminReportsRepository>()),
  );
  getIt.registerLazySingleton<FetchCompanySettingsUseCase>(
    () => FetchCompanySettingsUseCase(getIt<CompanySettingsRepository>()),
  );
  getIt.registerLazySingleton<UpdateCompanyVatRateUseCase>(
    () => UpdateCompanyVatRateUseCase(getIt<CompanySettingsRepository>()),
  );
  getIt.registerLazySingleton<UpdateCompanyAgreementTermsUseCase>(
    () =>
        UpdateCompanyAgreementTermsUseCase(getIt<CompanySettingsRepository>()),
  );
  getIt.registerLazySingleton<SaveCompanyPhoneUseCase>(
    () => SaveCompanyPhoneUseCase(getIt<CompanySettingsRepository>()),
  );
  getIt.registerLazySingleton<DeleteCompanyPhoneUseCase>(
    () => DeleteCompanyPhoneUseCase(getIt<CompanySettingsRepository>()),
  );
  getIt.registerLazySingleton<FetchDeliveryWorkersPageUseCase>(
    () => FetchDeliveryWorkersPageUseCase(getIt<StaffRepository>()),
  );
  getIt.registerLazySingleton<CreateDeliveryWorkerUseCase>(
    () => CreateDeliveryWorkerUseCase(getIt<StaffRepository>()),
  );
  getIt.registerLazySingleton<UpdateDeliveryWorkerUseCase>(
    () => UpdateDeliveryWorkerUseCase(getIt<StaffRepository>()),
  );
  getIt.registerLazySingleton<SuspendDeliveryWorkerUseCase>(
    () => SuspendDeliveryWorkerUseCase(getIt<StaffRepository>()),
  );
  getIt.registerLazySingleton<ReactivateDeliveryWorkerUseCase>(
    () => ReactivateDeliveryWorkerUseCase(getIt<StaffRepository>()),
  );
  getIt.registerLazySingleton<DeleteDeliveryWorkerUseCase>(
    () => DeleteDeliveryWorkerUseCase(getIt<StaffRepository>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      restoreSession: getIt<RestoreSessionUseCase>(),
      signIn: getIt<SignInUseCase>(),
      signOut: getIt<SignOutUseCase>(),
    ),
  );
  getIt.registerFactoryParam<DeliveryOrdersBloc, OrdersListScope, void>(
    (scope, _) => DeliveryOrdersBloc(
      fetchOrdersPage: getIt<FetchOrdersPageUseCase>(),
      markOrderDelivered: getIt<MarkOrderDeliveredUseCase>(),
      scope: scope,
    ),
  );
  getIt.registerFactory<CustomersListBloc>(
    () => CustomersListBloc(
      fetchCustomersPage: getIt<FetchCustomersPageUseCase>(),
    ),
  );
  getIt.registerFactory<CustomerDetailBloc>(
    () => CustomerDetailBloc(
      fetchDetail: getIt<FetchCustomerDetailUseCase>(),
      fetchOrders: getIt<FetchCommercialOrdersForCustomerUseCase>(),
    ),
  );
  getIt.registerFactoryParam<CustomerFormBloc, Customer?, void>(
    (existing, _) => CustomerFormBloc(
      createCustomer: getIt<CreateCustomerUseCase>(),
      updateCustomer: getIt<UpdateCustomerUseCase>(),
      existing: existing,
    ),
  );
  getIt.registerFactory<DeliveryWorkersListBloc>(
    () => DeliveryWorkersListBloc(
      fetchWorkers: getIt<FetchDeliveryWorkersPageUseCase>(),
      suspendWorker: getIt<SuspendDeliveryWorkerUseCase>(),
      reactivateWorker: getIt<ReactivateDeliveryWorkerUseCase>(),
      deleteWorker: getIt<DeleteDeliveryWorkerUseCase>(),
    ),
  );
  getIt.registerFactoryParam<DeliveryWorkerFormBloc, StaffProfile?, UserRole>(
    (existing, role) => DeliveryWorkerFormBloc(
      createWorker: getIt<CreateDeliveryWorkerUseCase>(),
      updateWorker: getIt<UpdateDeliveryWorkerUseCase>(),
      existing: existing,
      staffRole: role,
    ),
  );
  getIt.registerFactory<ProductDetailBloc>(
    () => ProductDetailBloc(fetchDetail: getIt<FetchProductDetailUseCase>()),
  );
  getIt.registerFactory<ProductsListBloc>(
    () =>
        ProductsListBloc(fetchProductsPage: getIt<FetchProductsPageUseCase>()),
  );
  getIt.registerFactoryParam<ProductFormBloc, Product?, void>(
    (existing, _) => ProductFormBloc(
      existing: existing,
      createProduct: getIt<CreateProductUseCase>(),
      updateProduct: getIt<UpdateProductUseCase>(),
      fetchProductDetail: getIt<FetchProductDetailUseCase>(),
      fetchStorageQuota: getIt<FetchStorageQuotaUseCase>(),
      fetchPropertyDefinitions: getIt<FetchProductPropertyDefinitionsUseCase>(),
    ),
  );
  getIt.registerFactory<PropertyDefinitionsListBloc>(
    () => PropertyDefinitionsListBloc(
      fetchDefinitions: getIt<FetchProductPropertyDefinitionsUseCase>(),
    ),
  );
  getIt.registerFactoryParam<
    PropertyDefinitionFormBloc,
    ProductPropertyDefinition?,
    void
  >(
    (existing, _) => PropertyDefinitionFormBloc(
      saveDefinition: getIt<SaveProductPropertyDefinitionUseCase>(),
      uploadPublicMedia: getIt<UploadPublicMediaUseCase>(),
      existing: existing,
    ),
  );
  getIt.registerFactory<AdminSettingsBloc>(
    () =>
        AdminSettingsBloc(fetchStorageQuota: getIt<FetchStorageQuotaUseCase>()),
  );
  getIt.registerFactory<AdminReportsBloc>(
    () => AdminReportsBloc(fetchReports: getIt<FetchAdminReportsUseCase>()),
  );
  getIt.registerFactory<CompanySettingsBloc>(
    () => CompanySettingsBloc(
      fetchSettings: getIt<FetchCompanySettingsUseCase>(),
      updateVatRate: getIt<UpdateCompanyVatRateUseCase>(),
      updateAgreementTerms: getIt<UpdateCompanyAgreementTermsUseCase>(),
      savePhone: getIt<SaveCompanyPhoneUseCase>(),
      deletePhone: getIt<DeleteCompanyPhoneUseCase>(),
    ),
  );

  getIt.registerLazySingleton<QuotePdfBuilder>(
    () => QuotePdfBuilder(getIt<CompanySettingsRepository>()),
  );
  getIt.registerLazySingleton<AgreementPdfBuilder>(
    () => AgreementPdfBuilder(getIt<CompanySettingsRepository>()),
  );
  getIt.registerLazySingleton<ManufacturingCardPdfBuilder>(
    () => ManufacturingCardPdfBuilder(getIt<CompanySettingsRepository>()),
  );
  getIt.registerLazySingleton<PdfShareService>(PdfShareService.new);

  getIt.registerFactory<WorkOrdersListBloc>(
    () => WorkOrdersListBloc(
      fetchOrdersPage: getIt<FetchCommercialOrdersPageUseCase>(),
    ),
  );
  getIt.registerFactory<WorkOrderDetailBloc>(
    () => WorkOrderDetailBloc(
      fetchDetail: getIt<FetchCommercialOrderDetailUseCase>(),
      fetchManufacturingCards: getIt<FetchManufacturingCardsUseCase>(),
      fetchFactories: getIt<FetchFactoriesUseCase>(),
      advancePhase: getIt<AdvanceCommercialOrderPhaseUseCase>(),
      assignFactory: getIt<AssignCommercialOrderFactoryUseCase>(),
      quotePdfBuilder: getIt<QuotePdfBuilder>(),
      agreementPdfBuilder: getIt<AgreementPdfBuilder>(),
      pdfShareService: getIt<PdfShareService>(),
    ),
  );
  getIt.registerFactory<WorkOrderCreateBloc>(
    () => WorkOrderCreateBloc(
      fetchFactories: getIt<FetchFactoriesUseCase>(),
      createOrder: getIt<CreateCommercialOrderUseCase>(),
    ),
  );
  getIt.registerFactory<QuoteFormBloc>(
    () => QuoteFormBloc(
      fetchDetail: getIt<FetchCommercialOrderDetailUseCase>(),
      saveQuote: getIt<SaveQuoteUseCase>(),
      fetchProducts: getIt<FetchProductsPageUseCase>(),
      fetchCompanySettings: getIt<FetchCompanySettingsUseCase>(),
      quotePdfBuilder: getIt<QuotePdfBuilder>(),
      pdfShareService: getIt<PdfShareService>(),
    ),
  );
  getIt.registerFactory<AgreementFormBloc>(
    () => AgreementFormBloc(
      fetchDetail: getIt<FetchCommercialOrderDetailUseCase>(),
      saveAgreement: getIt<SaveAgreementUseCase>(),
      fetchProducts: getIt<FetchProductsPageUseCase>(),
      agreementPdfBuilder: getIt<AgreementPdfBuilder>(),
      pdfShareService: getIt<PdfShareService>(),
    ),
  );
  getIt.registerFactory<ManufacturingCardsHubBloc>(
    () => ManufacturingCardsHubBloc(
      fetchDetail: getIt<FetchCommercialOrderDetailUseCase>(),
      fetchCards: getIt<FetchManufacturingCardsUseCase>(),
    ),
  );
  getIt.registerFactory<ManufacturingCardFormBloc>(
    () => ManufacturingCardFormBloc(
      fetchDetail: getIt<FetchCommercialOrderDetailUseCase>(),
      fetchCards: getIt<FetchManufacturingCardsUseCase>(),
      saveCard: getIt<SaveManufacturingCardUseCase>(),
      fetchProductDetail: getIt<FetchProductDetailUseCase>(),
      fetchPropertyDefinitions: getIt<FetchProductPropertyDefinitionsUseCase>(),
      appendProductImage: getIt<AppendProductImageUseCase>(),
      appendColorImage: getIt<AppendColorImageUseCase>(),
      uploadPublicMedia: getIt<UploadPublicMediaUseCase>(),
    ),
  );
}
