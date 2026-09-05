import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/debug/debug_flow_logs.dart';
import '../../core/errors/failures.dart';
import '../../core/supabase/supabase_error_mapper.dart';
import '../../domain/entities/agreement_terms.dart';
import '../../domain/entities/commercial_order.dart';
import '../../domain/entities/factory_profile.dart';
import '../../domain/entities/manufacturing_card.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/entities/user_role.dart';

class CommercialOrdersRemoteDataSource {
  CommercialOrdersRemoteDataSource(this._client);

  final SupabaseClient _client;

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  static const _factorySelect =
      'id, name_ar, name_en, short_name_ar, short_name_en, address_ar, '
      'address_en, phone, mobile, website, instagram, vat_number, '
      'commercial_register, bank_name, bank_account_name, iban, is_default, '
      'created_at, updated_at';

  static const _customerSnapshotSelect =
      'id, customer_number, customer_type, full_name, company_name, phone, '
      'address, governorate';

  static const _ordersPageSelect =
      'id, order_number, customer_id, factory_id, created_by, phase, notes, '
      'created_at, updated_at, '
      'customer:customers($_customerSnapshotSelect), '
      'quote:order_quotes(status), '
      'agreement:order_agreements(status)';

  static const _detailSelect =
      'id, order_number, customer_id, factory_id, created_by, phase, notes, '
      'created_at, updated_at, '
      'customer:customers($_customerSnapshotSelect), '
      'factory:factories($_factorySelect), '
      'quote:order_quotes('
      'id, order_id, quote_number, quote_date, specs_description, other_comments, '
      'discount_percent, discount_amount, extras_total, manufacturing_duration_days, '
      'subtotal, amount_after_discount, vat_rate, vat_amount, '
      'grand_total, total_in_words, status, pdf_storage_path, created_at, updated_at, '
      'lines:order_quote_lines('
      'id, quote_id, product_id, description, width_cm, height_cm, area_m2, '
      'quantity, unit_price, line_total, sort_order'
      '), '
      'extra_charges:order_quote_extra_charges('
      'id, quote_id, name, amount, sort_order'
      ')'
      '), '
      'agreement:order_agreements('
      'id, order_id, agreement_number, agreement_date, client_city, client_vat_number, '
      'manufacturing_days, down_payment, receipt_reference, discount_amount, extras_total, '
      'subtotal, vat_rate, vat_amount, grand_total, status, pdf_storage_path, '
      'terms_snapshot, created_at, updated_at, '
      'lines:order_agreement_lines('
      'id, agreement_id, product_id, description, quantity, color, width_cm, '
      'height_cm, unit_price, notes, sort_order'
      '), '
      'extra_charges:order_agreement_extra_charges('
      'id, agreement_id, name, amount, sort_order'
      ')'
      '), '
      'creator:profiles!commercial_orders_created_by_fkey(display_name, role)';

  Future<List<FactoryProfile>> fetchFactories() async {
    dbgWorkOrders('fetchFactories start');
    try {
      final rows = await _client
          .from('factories')
          .select(_factorySelect)
          .eq('is_active', true)
          .order('is_default', ascending: false)
          .order('created_at', ascending: true);

      final factories = (rows as List<dynamic>)
          .map((row) => _mapFactory(row as Map<String, dynamic>))
          .toList(growable: false);

      dbgWorkOrders('fetchFactories ok count=${factories.length}');
      return factories;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'fetchFactories',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'fetchFactories unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<PagedResult<CommercialOrderSummary>> fetchOrdersPage({
    required int page,
    required int pageSize,
  }) async {
    dbgWorkOrders('fetchOrdersPage start page=$page');
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      final response = await _client
          .from('commercial_orders')
          .select(_ordersPageSelect)
          .order('created_at', ascending: false)
          .range(from, to)
          .count(CountOption.exact);

      final rows = response.data as List<dynamic>;
      final items = rows
          .map((row) => _mapOrderSummary(row as Map<String, dynamic>))
          .toList(growable: false);

      dbgWorkOrders(
        'fetchOrdersPage ok count=${items.length} total=${response.count}',
      );
      return PagedResult(
        items: items,
        totalCount: response.count,
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'fetchOrdersPage',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'fetchOrdersPage unexpected',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<List<CommercialOrderSummary>> fetchOrdersForCustomer(
    String customerId,
  ) async {
    dbgWorkOrders('fetchOrdersForCustomer start customerId=$customerId');
    try {
      final rows = await _client
          .from('commercial_orders')
          .select(_ordersPageSelect)
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      final items = (rows as List<dynamic>)
          .map((row) => _mapOrderSummary(row as Map<String, dynamic>))
          .toList(growable: false);

      dbgWorkOrders(
        'fetchOrdersForCustomer ok customerId=$customerId count=${items.length}',
      );
      return items;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'fetchOrdersForCustomer',
        error: error,
        stackTrace: stackTrace,
        context: {'customerId': customerId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'fetchOrdersForCustomer unexpected',
        error: error,
        stackTrace: stackTrace,
        context: {'customerId': customerId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<CommercialOrderDetail> fetchOrderDetail(String orderId) async {
    dbgWorkOrders('fetchOrderDetail start orderId=$orderId');
    try {
      final row = await _client
          .from('commercial_orders')
          .select(_detailSelect)
          .eq('id', orderId)
          .maybeSingle();

      if (row == null) {
        throw const ServerFailure('لم يتم العثور على أمر العمل');
      }

      final detail = _mapOrderDetail(row);
      dbgWorkOrders('fetchOrderDetail ok orderId=$orderId');
      return detail;
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'fetchOrderDetail',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'fetchOrderDetail unexpected',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<CommercialOrderDetail> createOrder(
    CreateCommercialOrderInput input,
  ) async {
    dbgWorkOrders('createOrder start customerId=${input.customerId}');
    try {
      final inserted = await _client
          .from('commercial_orders')
          .insert({
            'customer_id': input.customerId,
            if (input.factoryId != null) 'factory_id': input.factoryId,
            if (input.notes != null && input.notes!.trim().isNotEmpty)
              'notes': input.notes!.trim(),
          })
          .select('id')
          .single();

      final orderId = inserted['id'] as String;
      await _client.from('order_quotes').insert({'order_id': orderId});

      final detail = await fetchOrderDetail(orderId);
      dbgWorkOrders('createOrder ok orderId=$orderId');
      return detail;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'createOrder',
        error: error,
        stackTrace: stackTrace,
        context: {'customerId': input.customerId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'createOrder unexpected',
        error: error,
        stackTrace: stackTrace,
        context: {'customerId': input.customerId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<OrderQuote> saveQuote({
    required String orderId,
    required QuoteDraft draft,
  }) async {
    dbgWorkOrders(
      'saveQuote start orderId=$orderId lines=${draft.lines.length}',
    );
    try {
      final quoteRow = await _client
          .from('order_quotes')
          .upsert({
            'order_id': orderId,
            'quote_date': _dateFmt.format(draft.quoteDate),
            'specs_description': draft.specsDescription?.trim(),
            'other_comments': draft.otherComments.trim().isEmpty
                ? defaultQuoteOtherCommentsText
                : draft.otherComments.trim(),
            'discount_percent': 0,
            'discount_amount': draft.discountAmount,
            'extras_total': draft.extrasTotal,
            'manufacturing_duration_days': draft.manufacturingDurationDays,
            'subtotal': draft.subtotal,
            'amount_after_discount': draft.amountAfterDiscount,
            'vat_rate': draft.vatRate,
            'vat_amount': draft.vatAmount,
            'grand_total': draft.grandTotal,
            'status': draft.status.dbValue,
          }, onConflict: 'order_id')
          .select('id')
          .single();

      final quoteId = quoteRow['id'] as String;

      await _client.from('order_quote_lines').delete().eq('quote_id', quoteId);
      await _client
          .from('order_quote_extra_charges')
          .delete()
          .eq('quote_id', quoteId);

      if (draft.lines.isNotEmpty) {
        await _client
            .from('order_quote_lines')
            .insert(
              draft.lines
                  .map(
                    (line) => {
                      'quote_id': quoteId,
                      'product_id': line.productId,
                      'description': line.description.trim(),
                      'width_cm': line.widthCm,
                      'height_cm': line.heightCm,
                      'area_m2': line.areaM2,
                      'quantity': line.quantity,
                      'unit_price': line.unitPrice,
                      'line_total': line.lineTotal,
                      'sort_order': line.sortOrder,
                    },
                  )
                  .toList(growable: false),
            );
      }

      if (draft.extraCharges.isNotEmpty) {
        await _client
            .from('order_quote_extra_charges')
            .insert(
              [
                for (var i = 0; i < draft.extraCharges.length; i++)
                  {
                    'quote_id': quoteId,
                    'name': draft.extraCharges[i].name.trim(),
                    'amount': draft.extraCharges[i].amount,
                    'sort_order': i,
                  },
              ],
            );
      }

      await _client
          .from('commercial_orders')
          .update({'phase': CommercialOrderPhase.quote.dbValue})
          .eq('id', orderId)
          .eq('phase', CommercialOrderPhase.quote.dbValue);

      final detail = await fetchOrderDetail(orderId);
      if (detail.quote == null) {
        throw const ServerFailure('تعذر حفظ عرض السعر');
      }
      dbgWorkOrders('saveQuote ok quoteId=$quoteId');
      return detail.quote!;
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'saveQuote',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'saveQuote unexpected',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<OrderAgreement> saveAgreement({
    required String orderId,
    required AgreementDraft draft,
  }) async {
    dbgWorkOrders(
      'saveAgreement start orderId=$orderId lines=${draft.lines.length}',
    );
    try {
      final termsSnapshot = await _resolveTermsSnapshot(orderId);
      final agreementRow = await _client
          .from('order_agreements')
          .upsert({
            'order_id': orderId,
            'agreement_date': _dateFmt.format(draft.agreementDate),
            'client_city': draft.clientCity?.trim(),
            'client_vat_number': draft.clientVatNumber?.trim(),
            'manufacturing_days': draft.manufacturingDays,
            'down_payment': draft.downPayment,
            'receipt_reference': draft.receiptReference?.trim(),
            'discount_amount': draft.discountAmount,
            'extras_total': draft.extrasTotal,
            'subtotal': draft.subtotal,
            'vat_rate': draft.vatRate,
            'vat_amount': draft.vatAmount,
            'grand_total': draft.grandTotal,
            'status': DocumentIssueStatus.draft.dbValue,
            'terms_snapshot': termsSnapshot,
          }, onConflict: 'order_id')
          .select('id')
          .single();

      final agreementId = agreementRow['id'] as String;

      await _client
          .from('order_agreement_lines')
          .delete()
          .eq('agreement_id', agreementId);
      await _client
          .from('order_agreement_extra_charges')
          .delete()
          .eq('agreement_id', agreementId);

      if (draft.lines.isNotEmpty) {
        await _client
            .from('order_agreement_lines')
            .insert(
              draft.lines
                  .map(
                    (line) => {
                      'agreement_id': agreementId,
                      'product_id': line.productId,
                      'description': line.description.trim(),
                      'quantity': line.quantity,
                      'color': line.color?.trim(),
                      'width_cm': line.widthCm,
                      'height_cm': line.heightCm,
                      'unit_price': line.unitPrice,
                      'notes': line.notes?.trim(),
                      'sort_order': line.sortOrder,
                    },
                  )
                  .toList(growable: false),
            );
      }

      if (draft.extraCharges.isNotEmpty) {
        await _client
            .from('order_agreement_extra_charges')
            .insert(
              [
                for (var i = 0; i < draft.extraCharges.length; i++)
                  {
                    'agreement_id': agreementId,
                    'name': draft.extraCharges[i].name.trim(),
                    'amount': draft.extraCharges[i].amount,
                    'sort_order': i,
                  },
              ],
            );
      }

      await _client
          .from('commercial_orders')
          .update({'phase': CommercialOrderPhase.agreement.dbValue})
          .eq('id', orderId)
          .eq('phase', CommercialOrderPhase.quote.dbValue);

      final detail = await fetchOrderDetail(orderId);
      if (detail.agreement == null) {
        throw const ServerFailure('تعذر حفظ الاتفاقية');
      }
      dbgWorkOrders('saveAgreement ok agreementId=$agreementId');
      await _syncAgreementLedger(detail);
      return detail.agreement!;
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'saveAgreement',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'saveAgreement unexpected',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<void> advancePhase({
    required String orderId,
    required CommercialOrderPhase phase,
  }) async {
    dbgWorkOrders('advancePhase start orderId=$orderId phase=${phase.dbValue}');
    try {
      final row = await _client
          .from('commercial_orders')
          .update({'phase': phase.dbValue})
          .eq('id', orderId)
          .select('id')
          .maybeSingle();

      if (row == null) {
        throw const ServerFailure('تعذر تحديث مرحلة أمر العمل');
      }
      if (phase == CommercialOrderPhase.completed ||
          phase == CommercialOrderPhase.delivered) {
        await _settleRemainingBalance(orderId);
      }
      dbgWorkOrders('advancePhase ok');
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'advancePhase',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId, 'phase': phase.dbValue},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<CommercialOrderDetail> assignFactory({
    required String orderId,
    required String factoryId,
  }) async {
    dbgWorkOrders('assignFactory start orderId=$orderId factoryId=$factoryId');
    try {
      final row = await _client
          .from('commercial_orders')
          .update({'factory_id': factoryId})
          .eq('id', orderId)
          .select('id')
          .maybeSingle();

      if (row == null) {
        throw const ServerFailure('تعذر تعيين المصنع');
      }
      final detail = await fetchOrderDetail(orderId);
      dbgWorkOrders('assignFactory ok');
      return detail;
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'assignFactory',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId, 'factoryId': factoryId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    } catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'assignFactory unexpected',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId, 'factoryId': factoryId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  static const _manufacturingCardSelect =
      'id, order_id, agreement_id, agreement_line_id, card_index, product_id, '
      'model_name_ar, model_name_en, width_cm, height_cm, color_id, '
      'color_name_ar, color_name_en, color_code, product_image_url, '
      'color_image_url, alert_note, notes, client_signed, status, '
      'pdf_storage_path, sort_order, created_at, updated_at, '
      'properties:order_manufacturing_card_properties('
      'id, card_id, definition_id, value_id, name_ar, name_en, value_ar, '
      'value_en, icon_key, image_url, sort_order'
      ')';

  Future<List<ManufacturingCard>> fetchManufacturingCards(
    String orderId,
  ) async {
    dbgWorkOrders('fetchManufacturingCards start orderId=$orderId');
    try {
      final rows = await _client
          .from('order_manufacturing_cards')
          .select(_manufacturingCardSelect)
          .eq('order_id', orderId)
          .order('sort_order', ascending: true)
          .order('card_index', ascending: true);

      final cards = (rows as List<dynamic>)
          .map((row) => _mapManufacturingCard(row as Map<String, dynamic>))
          .toList(growable: false);

      dbgWorkOrders('fetchManufacturingCards ok count=${cards.length}');
      return cards;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'fetchManufacturingCards',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  Future<ManufacturingCard> saveManufacturingCard({
    required String orderId,
    required String agreementId,
    required ManufacturingCardDraft draft,
  }) async {
    dbgWorkOrders(
      'saveManufacturingCard start orderId=$orderId '
      'line=${draft.agreementLineId} index=${draft.cardIndex}',
    );
    final validationError = draft.validationError;
    if (validationError != null) {
      throw ServerFailure(validationError);
    }

    final phaseRow = await _client
        .from('commercial_orders')
        .select('phase')
        .eq('id', orderId)
        .maybeSingle();
    final phase = CommercialOrderPhase.fromDbValue(
      (phaseRow?['phase'] as String?) ?? 'quote',
    );
    if (phase.isFinished) {
      throw const ServerFailure(
        'لا يمكن تعديل بطاقة التصنيع بعد اكتمال الطلب',
      );
    }

    try {
      final payload = <String, dynamic>{
        'order_id': orderId,
        'agreement_id': agreementId,
        'agreement_line_id': draft.agreementLineId,
        'card_index': draft.cardIndex,
        'product_id': draft.productId,
        'model_name_ar': draft.modelNameAr.trim(),
        'model_name_en': _nullableTrim(draft.modelNameEn),
        'width_cm': draft.widthCm,
        'height_cm': draft.heightCm,
        'color_id': draft.colorId,
        'color_name_ar': _nullableTrim(draft.colorNameAr),
        'color_name_en': _nullableTrim(draft.colorNameEn),
        'color_code': _nullableTrim(draft.colorCode),
        'product_image_url': _nullableTrim(draft.productImageUrl),
        'color_image_url': _nullableTrim(draft.colorImageUrl),
        'alert_note': draft.alertNote.trim().isEmpty
            ? defaultManufacturingCardAlert
            : draft.alertNote.trim(),
        'notes': _nullableTrim(draft.notes),
        'client_signed': draft.clientSigned,
        'status': draft.status.dbValue,
        'sort_order': draft.sortOrder,
      };

      final Map<String, dynamic> cardRow;
      if (draft.cardId != null) {
        cardRow = await _client
            .from('order_manufacturing_cards')
            .update(payload)
            .eq('id', draft.cardId!)
            .select(_manufacturingCardSelect)
            .single();
        await _client
            .from('order_manufacturing_card_properties')
            .delete()
            .eq('card_id', draft.cardId!);
      } else {
        cardRow = await _client
            .from('order_manufacturing_cards')
            .insert(payload)
            .select(_manufacturingCardSelect)
            .single();
      }

      final cardId = cardRow['id'] as String;
      if (draft.properties.isNotEmpty) {
        await _client
            .from('order_manufacturing_card_properties')
            .insert(
              draft.properties
                  .map(
                    (property) => {
                      'card_id': cardId,
                      'definition_id': property.definitionId,
                      'value_id': property.valueId,
                      'name_ar': property.nameAr.trim(),
                      'name_en': _nullableTrim(property.nameEn),
                      'value_ar': property.valueAr.trim(),
                      'value_en': _nullableTrim(property.valueEn),
                      'icon_key': property.iconKey,
                      'image_url': _nullableTrim(property.imageUrl),
                      'sort_order': property.sortOrder,
                    },
                  )
                  .toList(growable: false),
            );
      }

      // Cards stay as manufacturing drafts until the rep requests production.
      final order = await fetchOrderDetail(orderId);
      if (order.order.phase == CommercialOrderPhase.agreement ||
          order.order.phase == CommercialOrderPhase.quote) {
        await advancePhase(
          orderId: orderId,
          phase: CommercialOrderPhase.manufacturingDraft,
        );
      }

      final saved = await _client
          .from('order_manufacturing_cards')
          .select(_manufacturingCardSelect)
          .eq('id', cardId)
          .single();

      dbgWorkOrders('saveManufacturingCard ok id=$cardId');
      return _mapManufacturingCard(saved);
    } on ServerFailure {
      rethrow;
    } on PostgrestException catch (error, stackTrace) {
      SupabaseErrorMapper.logRemoteFailure(
        flowTag: 'WorkOrdersFlow',
        step: 'saveManufacturingCard',
        error: error,
        stackTrace: stackTrace,
        context: {'orderId': orderId, 'agreementId': agreementId},
      );
      throw ServerFailure(SupabaseErrorMapper.userMessage(error));
    }
  }

  ManufacturingCard _mapManufacturingCard(Map<String, dynamic> row) {
    final propertyRows = row['properties'] as List<dynamic>? ?? const [];
    final properties =
        propertyRows
            .map(
              (item) =>
                  _mapManufacturingCardProperty(item as Map<String, dynamic>),
            )
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return ManufacturingCard(
      id: row['id'] as String,
      orderId: row['order_id'] as String,
      agreementId: row['agreement_id'] as String,
      agreementLineId: row['agreement_line_id'] as String?,
      cardIndex: _parseInt(row['card_index']),
      productId: row['product_id'] as String?,
      modelNameAr: row['model_name_ar'] as String,
      modelNameEn: row['model_name_en'] as String?,
      widthCm: _parseDouble(row['width_cm']),
      heightCm: _parseDouble(row['height_cm']),
      colorId: row['color_id'] as String?,
      colorNameAr: row['color_name_ar'] as String?,
      colorNameEn: row['color_name_en'] as String?,
      colorCode: row['color_code'] as String?,
      productImageUrl: row['product_image_url'] as String?,
      colorImageUrl: row['color_image_url'] as String?,
      alertNote:
          (row['alert_note'] as String?) ?? defaultManufacturingCardAlert,
      notes: row['notes'] as String?,
      clientSigned: (row['client_signed'] as bool?) ?? false,
      status: DocumentIssueStatus.fromDbValue(row['status'] as String),
      pdfStoragePath: row['pdf_storage_path'] as String?,
      sortOrder: _parseInt(row['sort_order']),
      properties: properties,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  ManufacturingCardProperty _mapManufacturingCardProperty(
    Map<String, dynamic> row,
  ) {
    return ManufacturingCardProperty(
      id: row['id'] as String,
      cardId: row['card_id'] as String,
      definitionId: row['definition_id'] as String?,
      valueId: row['value_id'] as String?,
      nameAr: row['name_ar'] as String,
      nameEn: row['name_en'] as String?,
      valueAr: row['value_ar'] as String,
      valueEn: row['value_en'] as String?,
      iconKey: row['icon_key'] as String?,
      imageUrl: row['image_url'] as String?,
      sortOrder: _parseInt(row['sort_order']),
    );
  }

  String? _nullableTrim(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  CommercialOrderSummary _mapOrderSummary(Map<String, dynamic> row) {
    return CommercialOrderSummary(
      order: _mapCommercialOrder(row),
      customer: _mapCustomerSnapshot(row['customer'] as Map<String, dynamic>?),
      quoteStatus: _extractStatus(row['quote']),
      agreementStatus: _extractStatus(row['agreement']),
    );
  }

  CommercialOrderDetail _mapOrderDetail(Map<String, dynamic> row) {
    final creatorMap = row['creator'] as Map<String, dynamic>?;
    final quoteMap = _firstOrMap(row['quote']);
    final agreementMap = _firstOrMap(row['agreement']);

    return CommercialOrderDetail(
      order: _mapCommercialOrder(row),
      customer: _mapCustomerSnapshot(row['customer'] as Map<String, dynamic>?),
      factory: row['factory'] == null
          ? null
          : _mapFactory(row['factory'] as Map<String, dynamic>),
      quote: quoteMap == null
          ? null
          : _mapOrderQuote(quoteMap as Map<String, dynamic>),
      agreement: agreementMap == null
          ? null
          : _mapOrderAgreement(agreementMap as Map<String, dynamic>),
      createdBy: creatorMap == null ? null : _mapCreatorSnapshot(creatorMap),
    );
  }

  CommercialOrder _mapCommercialOrder(Map<String, dynamic> row) {
    return CommercialOrder(
      id: row['id'] as String,
      orderNumber: '${row['order_number']}',
      customerId: row['customer_id'] as String,
      factoryId: row['factory_id'] as String?,
      createdByProfileId: row['created_by'] as String,
      phase: CommercialOrderPhase.fromDbValue(row['phase'] as String),
      notes: row['notes'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  CommercialOrderCreatorSnapshot _mapCreatorSnapshot(Map<String, dynamic> row) {
    final role = row['role'] as String? ?? '';
    return CommercialOrderCreatorSnapshot(
      displayName: row['display_name'] as String? ?? '—',
      roleDbValue: role,
      roleLabelAr: role.isEmpty ? '—' : UserRole.fromDbValue(role).arabicLabel,
    );
  }

  CommercialOrderCustomerSnapshot _mapCustomerSnapshot(
    Map<String, dynamic>? row,
  ) {
    if (row == null) {
      throw const ServerFailure('بيانات العميل غير متاحة');
    }
    final type = row['customer_type'] as String? ?? 'individual';
    final displayName = type == 'company'
        ? (row['company_name'] as String? ?? '—')
        : (row['full_name'] as String? ?? '—');

    return CommercialOrderCustomerSnapshot(
      id: row['id'] as String,
      customerNumber: _parseInt(row['customer_number']),
      typeDbValue: type,
      displayName: displayName,
      phone: row['phone'] as String?,
      address: row['address'] as String?,
      governorate: row['governorate'] as String?,
    );
  }

  FactoryProfile _mapFactory(Map<String, dynamic> row) {
    final nameAr = row['name_ar'] as String;
    final nameEn = row['name_en'] as String? ?? '';
    final shortAr = (row['short_name_ar'] as String?)?.trim();
    final shortEn = (row['short_name_en'] as String?)?.trim();
    return FactoryProfile(
      id: row['id'] as String,
      nameAr: nameAr,
      nameEn: nameEn,
      shortNameAr: (shortAr == null || shortAr.isEmpty) ? nameAr : shortAr,
      shortNameEn: (shortEn == null || shortEn.isEmpty) ? nameEn : shortEn,
      addressAr: row['address_ar'] as String?,
      addressEn: row['address_en'] as String?,
      phone: row['phone'] as String?,
      mobile: row['mobile'] as String?,
      website: (row['website'] as String?) ?? 'ALMOUTAWA.COM',
      instagram: (row['instagram'] as String?) ?? '@ALMOUTAWA',
      vatNumber: row['vat_number'] as String?,
      commercialRegister: row['commercial_register'] as String?,
      bankName: row['bank_name'] as String?,
      bankAccountName: row['bank_account_name'] as String?,
      iban: row['iban'] as String?,
      isDefault: (row['is_default'] as bool?) ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  OrderQuote _mapOrderQuote(Map<String, dynamic> row) {
    final lines =
        (row['lines'] as List<dynamic>? ?? const [])
            .map((l) => _mapQuoteLine(l as Map<String, dynamic>))
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final extras =
        (row['extra_charges'] as List<dynamic>? ?? const [])
            .map((item) => _mapExtraCharge(item as Map<String, dynamic>))
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return OrderQuote(
      id: row['id'] as String,
      commercialOrderId: row['order_id'] as String,
      quoteNumber: _parseInt(row['quote_number']),
      quoteDate: DateTime.parse(row['quote_date'] as String),
      specsDescription: (row['specs_description'] as String?) ?? '',
      otherComments:
          (row['other_comments'] as String?) ?? defaultQuoteOtherCommentsText,
      discountPercent: _parseDouble(row['discount_percent']),
      discountAmount: _parseDouble(row['discount_amount']),
      extrasTotal: _parseDouble(row['extras_total']),
      extraCharges: extras,
      manufacturingDurationDays: row['manufacturing_duration_days'] == null
          ? null
          : _parseInt(row['manufacturing_duration_days']),
      subtotal: _parseDouble(row['subtotal']),
      amountAfterDiscount: _parseDouble(row['amount_after_discount']),
      vatRate: _parseDouble(row['vat_rate']),
      vatAmount: _parseDouble(row['vat_amount']),
      grandTotal: _parseDouble(row['grand_total']),
      totalInWords: row['total_in_words'] as String?,
      status: DocumentIssueStatus.fromDbValue(row['status'] as String),
      pdfStoragePath: row['pdf_storage_path'] as String?,
      lines: lines,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  DocumentExtraCharge _mapExtraCharge(Map<String, dynamic> row) {
    return DocumentExtraCharge(
      id: row['id'] as String?,
      name: (row['name'] as String?) ?? '',
      amount: _parseDouble(row['amount']),
      sortOrder: _parseInt(row['sort_order']),
    );
  }

  QuoteLine _mapQuoteLine(Map<String, dynamic> row) {
    return QuoteLine(
      id: row['id'] as String,
      orderQuoteId: row['quote_id'] as String,
      productId: row['product_id'] as String?,
      description: row['description'] as String,
      widthCm: _parseDouble(row['width_cm']),
      heightCm: _parseDouble(row['height_cm']),
      areaM2: _parseDouble(row['area_m2']),
      quantity: _parseInt(row['quantity']),
      unitPrice: _parseDouble(row['unit_price']),
      lineTotal: _parseDouble(row['line_total']),
      sortOrder: _parseInt(row['sort_order']),
    );
  }

  OrderAgreement _mapOrderAgreement(Map<String, dynamic> row) {
    final lines =
        (row['lines'] as List<dynamic>? ?? const [])
            .map((l) => _mapAgreementLine(l as Map<String, dynamic>))
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final extras =
        (row['extra_charges'] as List<dynamic>? ?? const [])
            .map((item) => _mapExtraCharge(item as Map<String, dynamic>))
            .toList(growable: false)
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return OrderAgreement(
      id: row['id'] as String,
      commercialOrderId: row['order_id'] as String,
      agreementNumber: _parseInt(row['agreement_number']),
      agreementDate: DateTime.parse(row['agreement_date'] as String),
      clientCity: row['client_city'] as String?,
      clientVatNumber: row['client_vat_number'] as String?,
      manufacturingDays: row['manufacturing_days'] == null
          ? null
          : _parseInt(row['manufacturing_days']),
      downPayment: _parseDouble(row['down_payment']),
      receiptReference: row['receipt_reference'] as String?,
      discountAmount: _parseDouble(row['discount_amount']),
      extrasTotal: _parseDouble(row['extras_total']),
      extraCharges: extras,
      subtotal: _parseDouble(row['subtotal']),
      vatRate: _parseDouble(row['vat_rate']),
      vatAmount: _parseDouble(row['vat_amount']),
      grandTotal: _parseDouble(row['grand_total']),
      status: DocumentIssueStatus.fromDbValue(row['status'] as String),
      pdfStoragePath: row['pdf_storage_path'] as String?,
      termsSnapshot: row['terms_snapshot'] as String?,
      lines: lines,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  AgreementLine _mapAgreementLine(Map<String, dynamic> row) {
    return AgreementLine(
      id: row['id'] as String,
      agreementId: row['agreement_id'] as String,
      productId: row['product_id'] as String?,
      description: row['description'] as String,
      quantity: row['quantity'] == null ? null : _parseDouble(row['quantity']),
      color: row['color'] as String?,
      widthCm: row['width_cm'] == null ? null : _parseDouble(row['width_cm']),
      heightCm: row['height_cm'] == null
          ? null
          : _parseDouble(row['height_cm']),
      unitPrice: _parseDouble(row['unit_price']),
      notes: row['notes'] as String?,
      sortOrder: _parseInt(row['sort_order']),
    );
  }

  DocumentIssueStatus? _extractStatus(Object? value) {
    final map = _firstOrMap(value);
    if (map == null) return null;
    final status = (map as Map<String, dynamic>)['status'] as String?;
    return status == null ? null : DocumentIssueStatus.fromDbValue(status);
  }

  Object? _firstOrMap(Object? value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is List<dynamic>) {
      return value.isEmpty ? null : value.first;
    }
    return null;
  }

  double _parseDouble(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  int _parseInt(Object? value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<void> _syncAgreementLedger(CommercialOrderDetail detail) async {
    final agreement = detail.agreement;
    if (agreement == null || agreement.grandTotal <= 0) return;
    final collectorName = (detail.createdBy?.displayName ?? '').trim();
    final collectorLabel = collectorName.isEmpty ? 'المندوب' : collectorName;
    await _client
        .from('customer_account_entries')
        .delete()
        .eq('reference_type', 'order_agreement')
        .eq('reference_id', agreement.id);
    final rows = <Map<String, dynamic>>[
      {
        'customer_id': detail.customer.id,
        'entry_type': 'debit',
        'amount': agreement.grandTotal,
        'description':
            'قيمة اتفاقية #${agreement.agreementNumber} — طلب ${detail.order.orderNumber}',
        'reference_type': 'order_agreement',
        'reference_id': agreement.id,
        'commercial_order_id': detail.order.id,
        'collected_by_profile_id': detail.order.createdByProfileId,
        'entry_kind': 'agreement_value',
      },
    ];
    if (agreement.downPayment > 0) {
      rows.add({
        'customer_id': detail.customer.id,
        'entry_type': 'credit',
        'amount': agreement.downPayment,
        'description':
            'دفعة مقدمة اتفاقية #${agreement.agreementNumber} — استلمها $collectorLabel',
        'reference_type': 'order_agreement',
        'reference_id': agreement.id,
        'commercial_order_id': detail.order.id,
        'collected_by_profile_id': detail.order.createdByProfileId,
        'entry_kind': 'agreement_deposit',
      });
    }
    await _client.from('customer_account_entries').insert(rows);
  }

  Future<void> _settleRemainingBalance(String orderId) async {
    final detail = await fetchOrderDetail(orderId);
    final agreement = detail.agreement;
    if (agreement == null || agreement.grandTotal <= 0) return;

    final existing = await _client
        .from('customer_account_entries')
        .select('id')
        .eq('reference_id', agreement.id)
        .eq('entry_kind', 'agreement_settlement')
        .maybeSingle();
    if (existing != null) return;

    final remaining = double.parse(
      (agreement.grandTotal - agreement.downPayment).toStringAsFixed(2),
    );
    if (remaining <= 0) return;

    await _client.from('customer_account_entries').insert({
      'customer_id': detail.customer.id,
      'entry_type': 'credit',
      'amount': remaining,
      'description':
          'تسوية متبقي اتفاقية #${agreement.agreementNumber} — طلب ${detail.order.orderNumber}',
      'reference_type': 'order_settlement',
      'reference_id': agreement.id,
      'commercial_order_id': detail.order.id,
      'collected_by_profile_id': detail.order.createdByProfileId,
      'entry_kind': 'agreement_settlement',
    });
  }

  Future<String> _resolveTermsSnapshot(String orderId) async {
    try {
      final existing = await _client
          .from('order_agreements')
          .select('terms_snapshot')
          .eq('order_id', orderId)
          .maybeSingle();
      final stored = (existing?['terms_snapshot'] as String?)?.trim() ?? '';
      if (stored.isNotEmpty) return stored;
    } catch (_) {}
    try {
      final settings = await _client
          .from('company_settings')
          .select('agreement_terms_ar')
          .limit(1)
          .maybeSingle();
      final fromSettings =
          (settings?['agreement_terms_ar'] as String?)?.trim() ?? '';
      if (fromSettings.isNotEmpty) return fromSettings;
    } catch (_) {}
    return defaultAgreementTermsAr;
  }
}
