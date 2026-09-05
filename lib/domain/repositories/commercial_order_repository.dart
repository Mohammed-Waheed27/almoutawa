import '../entities/commercial_order.dart';
import '../entities/factory_profile.dart';
import '../entities/manufacturing_card.dart';
import '../entities/paged_result.dart';

const commercialOrdersPageSize = 20;

abstract class CommercialOrderRepository {
  Future<List<FactoryProfile>> fetchFactories();

  Future<PagedResult<CommercialOrderSummary>> fetchOrdersPage({
    required int page,
    int pageSize = commercialOrdersPageSize,
  });

  Future<List<CommercialOrderSummary>> fetchOrdersForCustomer(
    String customerId,
  );

  Future<CommercialOrderDetail> fetchOrderDetail(String orderId);

  Future<CommercialOrderDetail> createOrder(CreateCommercialOrderInput input);

  Future<OrderQuote> saveQuote({
    required String orderId,
    required QuoteDraft draft,
  });

  Future<OrderAgreement> saveAgreement({
    required String orderId,
    required AgreementDraft draft,
  });

  Future<List<ManufacturingCard>> fetchManufacturingCards(String orderId);

  Future<ManufacturingCard> saveManufacturingCard({
    required String orderId,
    required String agreementId,
    required ManufacturingCardDraft draft,
  });

  Future<void> advancePhase({
    required String orderId,
    required CommercialOrderPhase phase,
  });

  Future<CommercialOrderDetail> assignFactory({
    required String orderId,
    required String factoryId,
  });

  String defaultQuoteOtherComments();
}
