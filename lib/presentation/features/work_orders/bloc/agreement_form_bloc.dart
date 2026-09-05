import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../core/pdf/agreement_pdf_builder.dart';
import '../../../../core/pdf/pdf_share_service.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/usecases/commercial_order_usecases.dart';
import '../../../../domain/usecases/product_usecases.dart';

class AgreementFormBloc extends Bloc<AgreementFormEvent, AgreementFormState> {
  AgreementFormBloc({
    required FetchCommercialOrderDetailUseCase fetchDetail,
    required SaveAgreementUseCase saveAgreement,
    required FetchProductsPageUseCase fetchProducts,
    required AgreementPdfBuilder agreementPdfBuilder,
    required PdfShareService pdfShareService,
  }) : _fetchDetail = fetchDetail,
       _saveAgreement = saveAgreement,
       _fetchProducts = fetchProducts,
       _agreementPdfBuilder = agreementPdfBuilder,
       _pdfShareService = pdfShareService,
       super(const AgreementFormState()) {
    on<AgreementFormStarted>(_onStarted);
    on<AgreementFormFieldChanged>(_onFieldChanged);
    on<AgreementFormLineAdded>(_onLineAdded);
    on<AgreementFormLineRemoved>(_onLineRemoved);
    on<AgreementFormLineUpdated>(_onLineUpdated);
    on<AgreementFormProductPicked>(_onProductPicked);
    on<AgreementFormSeedFromQuote>(_onSeedFromQuote);
    on<AgreementFormExtrasChanged>(_onExtras);
    on<AgreementFormSubmitted>(_onSubmitted);
  }

  final FetchCommercialOrderDetailUseCase _fetchDetail;
  final SaveAgreementUseCase _saveAgreement;
  final FetchProductsPageUseCase _fetchProducts;
  final AgreementPdfBuilder _agreementPdfBuilder;
  final PdfShareService _pdfShareService;

  Future<void> _onStarted(
    AgreementFormStarted event,
    Emitter<AgreementFormState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AgreementFormStatus.loading,
        orderId: event.orderId,
      ),
    );
    final detailResult = await _fetchDetail(event.orderId);
    final productsResult = await _fetchProducts(page: 0);

    CommercialOrderDetail? detail;
    List<Product> products = const [];
    String? error;
    detailResult.fold((f) => error = f.message, (v) => detail = v);
    productsResult.fold((f) => error ??= f.message, (v) => products = v.items);

    if (error != null || detail == null) {
      emit(state.copyWith(status: AgreementFormStatus.failure, message: error));
      return;
    }

    final agreement = detail!.agreement;
    final quote = detail!.quote;
    final lines = agreement != null
        ? agreement.lines
              .map(
                (l) => AgreementLineDraft(
                  productId: l.productId,
                  description: l.description,
                  quantity: l.quantity,
                  color: l.color,
                  widthCm: l.widthCm,
                  heightCm: l.heightCm,
                  unitPrice: l.unitPrice,
                  notes: l.notes,
                  sortOrder: l.sortOrder,
                ),
              )
              .toList()
        : (quote != null && quote.lines.isNotEmpty)
        ? [
            for (var i = 0; i < quote.lines.length; i++)
              AgreementLineDraft(
                productId: quote.lines[i].productId,
                description: quote.lines[i].description,
                quantity: quote.lines[i].quantity.toDouble(),
                widthCm: quote.lines[i].widthCm,
                heightCm: quote.lines[i].heightCm,
                unitPrice: quote.lines[i].unitPrice,
                sortOrder: i,
              ),
          ]
        : [const AgreementLineDraft(description: '', unitPrice: 0, sortOrder: 0)];

    emit(
      state.copyWith(
        status: AgreementFormStatus.ready,
        detail: detail,
        products: products,
        clientCity: agreement?.clientCity ?? detail!.customer.governorate ?? '',
        clientVatNumber: agreement?.clientVatNumber ?? '',
        manufacturingDays:
            agreement?.manufacturingDays ??
            detail!.quote?.manufacturingDurationDays,
        downPayment: agreement?.downPayment ?? 0,
        receiptReference: agreement?.receiptReference ?? '',
        discountAmount:
            agreement?.discountAmount ??
            detail!.quote?.resolvedDiscountAmount ??
            0,
        vatRate: agreement?.vatRate ?? detail!.quote?.vatRate ?? defaultVatRate,
        extraCharges:
            agreement?.extraCharges ?? detail!.quote?.extraCharges ?? const [],
        lines: lines,
        message: null,
      ),
    );
  }

  void _onFieldChanged(
    AgreementFormFieldChanged event,
    Emitter<AgreementFormState> emit,
  ) {
    emit(
      state.copyWith(
        clientCity: event.clientCity,
        clientVatNumber: event.clientVatNumber,
        manufacturingDays: event.manufacturingDays,
        clearManufacturingDays: event.clearManufacturingDays,
        downPayment: event.downPayment,
        receiptReference: event.receiptReference,
        discountAmount: event.discountAmount,
      ),
    );
  }

  void _onLineAdded(
    AgreementFormLineAdded event,
    Emitter<AgreementFormState> emit,
  ) {
    final lines = [...state.lines];
    lines.add(
      AgreementLineDraft(
        description: '',
        quantity: 1,
        unitPrice: 0,
        sortOrder: lines.length,
      ),
    );
    emit(state.copyWith(lines: lines));
  }

  void _onLineRemoved(
    AgreementFormLineRemoved event,
    Emitter<AgreementFormState> emit,
  ) {
    if (state.lines.length <= 1) return;
    final lines = [...state.lines]..removeAt(event.index);
    emit(
      state.copyWith(
        lines: [
          for (var i = 0; i < lines.length; i++)
            AgreementLineDraft(
              productId: lines[i].productId,
              description: lines[i].description,
              quantity: lines[i].quantity,
              color: lines[i].color,
              widthCm: lines[i].widthCm,
              heightCm: lines[i].heightCm,
              unitPrice: lines[i].unitPrice,
              notes: lines[i].notes,
              sortOrder: i,
            ),
        ],
      ),
    );
  }

  void _onLineUpdated(
    AgreementFormLineUpdated event,
    Emitter<AgreementFormState> emit,
  ) {
    final lines = [...state.lines];
    if (event.index < 0 || event.index >= lines.length) return;
    lines[event.index] = event.line;
    emit(state.copyWith(lines: lines));
  }

  void _onProductPicked(
    AgreementFormProductPicked event,
    Emitter<AgreementFormState> emit,
  ) {
    final lines = [...state.lines];
    if (event.index < 0 || event.index >= lines.length) return;
    final current = lines[event.index];
    lines[event.index] = AgreementLineDraft(
      productId: event.product.id,
      description: event.product.name,
      quantity: current.quantity ?? 1,
      color: current.color,
      widthCm: current.widthCm,
      heightCm: current.heightCm,
      unitPrice: event.product.unitPrice,
      notes: current.notes,
      sortOrder: current.sortOrder,
    );
    emit(state.copyWith(lines: lines));
  }

  void _onSeedFromQuote(
    AgreementFormSeedFromQuote event,
    Emitter<AgreementFormState> emit,
  ) {
    final quote = state.detail?.quote;
    if (quote == null || quote.lines.isEmpty) {
      dbgWorkOrders('agreement seed-from-quote blocked: no quote lines');
      emit(state.copyWith(message: 'لا يوجد عرض سعر للنسخ منه'));
      return;
    }

    final lines = [
      for (var i = 0; i < quote.lines.length; i++)
        AgreementLineDraft(
          productId: quote.lines[i].productId,
          description: quote.lines[i].description,
          quantity: quote.lines[i].quantity.toDouble(),
          widthCm: quote.lines[i].widthCm,
          heightCm: quote.lines[i].heightCm,
          unitPrice: quote.lines[i].unitPrice,
          sortOrder: i,
        ),
    ];

    dbgWorkOrders(
      'agreement seed-from-quote ok lines=${lines.length} gen=${state.copyGeneration + 1}',
    );
    emit(
      state.copyWith(
        lines: lines,
        extraCharges: quote.extraCharges,
        discountAmount: quote.resolvedDiscountAmount,
        vatRate: quote.vatRate,
        manufacturingDays: quote.manufacturingDurationDays,
        clearManufacturingDays: quote.manufacturingDurationDays == null,
        copyGeneration: state.copyGeneration + 1,
        message: 'تم نسخ البنود والمصاريف من عرض السعر',
      ),
    );
  }

  void _onExtras(
    AgreementFormExtrasChanged event,
    Emitter<AgreementFormState> emit,
  ) {
    emit(state.copyWith(extraCharges: event.charges));
  }

  Future<void> _onSubmitted(
    AgreementFormSubmitted event,
    Emitter<AgreementFormState> emit,
  ) async {
    final orderId = state.orderId;
    if (orderId == null) return;

    final draft = AgreementDraft(
      agreementDate: DateTime.now(),
      clientCity: state.clientCity,
      clientVatNumber: state.clientVatNumber,
      manufacturingDays: state.manufacturingDays,
      downPayment: state.downPayment,
      receiptReference: state.receiptReference,
      discountAmount: state.discountAmount,
      vatRate: state.vatRate,
      extraCharges: state.extraCharges,
      lines: state.lines,
    );

    final validation = draft.validationError;
    if (validation != null) {
      emit(state.copyWith(message: validation));
      return;
    }

    emit(state.copyWith(status: AgreementFormStatus.saving, message: null));
    final result = await _saveAgreement(orderId: orderId, draft: draft);
    await result.fold(
      (failure) async {
        dbgWorkOrdersError('agreement save failed', error: failure.message);
        emit(
          state.copyWith(
            status: AgreementFormStatus.ready,
            message: failure.message,
          ),
        );
      },
      (agreement) async {
        dbgWorkOrders('agreement saved #${agreement.agreementNumber}');
        final detailResult = await _fetchDetail(orderId);
        final detail = detailResult.fold((_) => null, (d) => d);
        if (detail != null && event.sharePdf) {
          try {
            if (!event.context.mounted) return;
            final bytes = await _agreementPdfBuilder.build(
              detail,
              context: event.context,
            );
            final file = await _pdfShareService.saveBytes(
              bytes: bytes,
              fileName: 'agreement-${agreement.agreementNumber}.pdf',
            );
            await _pdfShareService.shareFile(
              file: file,
              subject: 'اتفاقية عمل ${agreement.agreementNumber}',
            );
          } catch (e, st) {
            dbgWorkOrdersError(
              'agreement pdf failed',
              error: e,
              stackTrace: st,
            );
          }
        }
        emit(
          state.copyWith(
            status: AgreementFormStatus.success,
            detail: detail,
            message: 'تم حفظ الاتفاقية',
          ),
        );
      },
    );
  }
}

sealed class AgreementFormEvent extends Equatable {
  const AgreementFormEvent();
  @override
  List<Object?> get props => [];
}

class AgreementFormStarted extends AgreementFormEvent {
  const AgreementFormStarted(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

class AgreementFormFieldChanged extends AgreementFormEvent {
  const AgreementFormFieldChanged({
    this.clientCity,
    this.clientVatNumber,
    this.manufacturingDays,
    this.downPayment,
    this.receiptReference,
    this.discountAmount,
    this.clearManufacturingDays = false,
  });
  final String? clientCity;
  final String? clientVatNumber;
  final int? manufacturingDays;
  final double? downPayment;
  final String? receiptReference;
  final double? discountAmount;
  final bool clearManufacturingDays;
}

class AgreementFormExtrasChanged extends AgreementFormEvent {
  const AgreementFormExtrasChanged(this.charges);
  final List<DocumentExtraCharge> charges;
  @override
  List<Object?> get props => [charges];
}

class AgreementFormLineAdded extends AgreementFormEvent {
  const AgreementFormLineAdded();
}

class AgreementFormLineRemoved extends AgreementFormEvent {
  const AgreementFormLineRemoved(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class AgreementFormLineUpdated extends AgreementFormEvent {
  const AgreementFormLineUpdated(this.index, this.line);
  final int index;
  final AgreementLineDraft line;
  @override
  List<Object?> get props => [index, line];
}

class AgreementFormProductPicked extends AgreementFormEvent {
  const AgreementFormProductPicked(this.index, this.product);
  final int index;
  final Product product;
  @override
  List<Object?> get props => [index, product];
}

class AgreementFormSeedFromQuote extends AgreementFormEvent {
  const AgreementFormSeedFromQuote();
}

class AgreementFormSubmitted extends AgreementFormEvent {
  const AgreementFormSubmitted({this.sharePdf = false, required this.context});
  final bool sharePdf;
  final BuildContext context;
  @override
  List<Object?> get props => [sharePdf];
}

enum AgreementFormStatus { initial, loading, ready, saving, success, failure }

class AgreementFormState extends Equatable {
  const AgreementFormState({
    this.status = AgreementFormStatus.initial,
    this.orderId,
    this.detail,
    this.products = const [],
    this.clientCity = '',
    this.clientVatNumber = '',
    this.manufacturingDays,
    this.downPayment = 0,
    this.receiptReference = '',
    this.discountAmount = 0,
    this.vatRate = defaultVatRate,
    this.extraCharges = const [],
    this.lines = const [],
    this.copyGeneration = 0,
    this.message,
  });

  final AgreementFormStatus status;
  final String? orderId;
  final CommercialOrderDetail? detail;
  final List<Product> products;
  final String clientCity;
  final String clientVatNumber;
  final int? manufacturingDays;
  final double downPayment;
  final String receiptReference;
  final double discountAmount;
  final double vatRate;
  final List<DocumentExtraCharge> extraCharges;
  final List<AgreementLineDraft> lines;

  /// Bumps when lines are replaced from quote — UI sync + copy animation.
  final int copyGeneration;
  final String? message;

  AgreementFormState copyWith({
    AgreementFormStatus? status,
    String? orderId,
    CommercialOrderDetail? detail,
    List<Product>? products,
    String? clientCity,
    String? clientVatNumber,
    int? manufacturingDays,
    bool clearManufacturingDays = false,
    double? downPayment,
    String? receiptReference,
    double? discountAmount,
    double? vatRate,
    List<DocumentExtraCharge>? extraCharges,
    List<AgreementLineDraft>? lines,
    int? copyGeneration,
    String? message,
  }) {
    return AgreementFormState(
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      detail: detail ?? this.detail,
      products: products ?? this.products,
      clientCity: clientCity ?? this.clientCity,
      clientVatNumber: clientVatNumber ?? this.clientVatNumber,
      manufacturingDays: clearManufacturingDays
          ? manufacturingDays
          : (manufacturingDays ?? this.manufacturingDays),
      downPayment: downPayment ?? this.downPayment,
      receiptReference: receiptReference ?? this.receiptReference,
      discountAmount: discountAmount ?? this.discountAmount,
      vatRate: vatRate ?? this.vatRate,
      extraCharges: extraCharges ?? this.extraCharges,
      lines: lines ?? this.lines,
      copyGeneration: copyGeneration ?? this.copyGeneration,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    orderId,
    detail,
    products,
    clientCity,
    clientVatNumber,
    manufacturingDays,
    downPayment,
    receiptReference,
    discountAmount,
    vatRate,
    extraCharges,
    lines,
    copyGeneration,
    message,
  ];
}
