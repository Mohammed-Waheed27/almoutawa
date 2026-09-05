import '../../domain/entities/commercial_order.dart';
import '../../domain/entities/factory_profile.dart';
import '../../domain/entities/manufacturing_card.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/repositories/commercial_order_repository.dart';
import '../datasources/commercial_orders_remote_data_source.dart';

class CommercialOrderRepositoryImpl implements CommercialOrderRepository {
  CommercialOrderRepositoryImpl(this._remote);

  final CommercialOrdersRemoteDataSource _remote;

  @override
  Future<List<FactoryProfile>> fetchFactories() => _remote.fetchFactories();

  @override
  Future<PagedResult<CommercialOrderSummary>> fetchOrdersPage({
    required int page,
    int pageSize = commercialOrdersPageSize,
  }) {
    return _remote.fetchOrdersPage(page: page, pageSize: pageSize);
  }

  @override
  Future<List<CommercialOrderSummary>> fetchOrdersForCustomer(
    String customerId,
  ) {
    return _remote.fetchOrdersForCustomer(customerId);
  }

  @override
  Future<CommercialOrderDetail> fetchOrderDetail(String orderId) {
    return _remote.fetchOrderDetail(orderId);
  }

  @override
  Future<CommercialOrderDetail> createOrder(CreateCommercialOrderInput input) {
    return _remote.createOrder(input);
  }

  @override
  Future<OrderQuote> saveQuote({
    required String orderId,
    required QuoteDraft draft,
  }) {
    return _remote.saveQuote(orderId: orderId, draft: draft);
  }

  @override
  Future<OrderAgreement> saveAgreement({
    required String orderId,
    required AgreementDraft draft,
  }) {
    return _remote.saveAgreement(orderId: orderId, draft: draft);
  }

  @override
  Future<List<ManufacturingCard>> fetchManufacturingCards(String orderId) {
    return _remote.fetchManufacturingCards(orderId);
  }

  @override
  Future<ManufacturingCard> saveManufacturingCard({
    required String orderId,
    required String agreementId,
    required ManufacturingCardDraft draft,
  }) {
    return _remote.saveManufacturingCard(
      orderId: orderId,
      agreementId: agreementId,
      draft: draft,
    );
  }

  @override
  Future<void> advancePhase({
    required String orderId,
    required CommercialOrderPhase phase,
  }) {
    return _remote.advancePhase(orderId: orderId, phase: phase);
  }

  @override
  Future<CommercialOrderDetail> assignFactory({
    required String orderId,
    required String factoryId,
  }) {
    return _remote.assignFactory(orderId: orderId, factoryId: factoryId);
  }

  @override
  String defaultQuoteOtherComments() => defaultQuoteOtherCommentsText;
}
