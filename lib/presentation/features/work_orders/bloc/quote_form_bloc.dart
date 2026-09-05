import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../core/pdf/pdf_share_service.dart';
import '../../../../core/pdf/quote_pdf_builder.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/product.dart';
import '../../../../domain/usecases/commercial_order_usecases.dart';
import '../../../../domain/usecases/company_settings_usecases.dart';
import '../../../../domain/usecases/product_usecases.dart';

class QuoteFormBloc extends Bloc<QuoteFormEvent, QuoteFormState> {
  QuoteFormBloc({
    required FetchCommercialOrderDetailUseCase fetchDetail,
    required SaveQuoteUseCase saveQuote,
    required FetchProductsPageUseCase fetchProducts,
    required FetchCompanySettingsUseCase fetchCompanySettings,
    required QuotePdfBuilder quotePdfBuilder,
    required PdfShareService pdfShareService,
  }) : _fetchDetail = fetchDetail,
       _saveQuote = saveQuote,
       _fetchProducts = fetchProducts,
       _fetchCompanySettings = fetchCompanySettings,
       _quotePdfBuilder = quotePdfBuilder,
       _pdfShareService = pdfShareService,
       super(const QuoteFormState()) {
    on<QuoteFormStarted>(_onStarted);
    on<QuoteFormSpecsChanged>(_onSpecs);
    on<QuoteFormCommentsChanged>(_onComments);
    on<QuoteFormDiscountChanged>(_onDiscount);
    on<QuoteFormDurationChanged>(_onDuration);
    on<QuoteFormExtrasChanged>(_onExtras);
    on<QuoteFormDateChanged>(_onDateChanged);
    on<QuoteFormLineAdded>(_onLineAdded);
    on<QuoteFormLineRemoved>(_onLineRemoved);
    on<QuoteFormLineUpdated>(_onLineUpdated);
    on<QuoteFormProductPicked>(_onProductPicked);
    on<QuoteFormSubmitted>(_onSubmitted);
  }

  final FetchCommercialOrderDetailUseCase _fetchDetail;
  final SaveQuoteUseCase _saveQuote;
  final FetchProductsPageUseCase _fetchProducts;
  final FetchCompanySettingsUseCase _fetchCompanySettings;
  final QuotePdfBuilder _quotePdfBuilder;
  final PdfShareService _pdfShareService;

  Future<void> _onStarted(
    QuoteFormStarted event,
    Emitter<QuoteFormState> emit,
  ) async {
    emit(
      state.copyWith(status: QuoteFormStatus.loading, orderId: event.orderId),
    );
    final detailResult = await _fetchDetail(event.orderId);
    final productsResult = await _fetchProducts(page: 0, pageSize: 100);

    CommercialOrderDetail? detail;
    List<Product> products = const [];
    String? error;

    detailResult.fold((f) => error = f.message, (v) => detail = v);
    productsResult.fold((f) => error ??= f.message, (v) => products = v.items);

    if (error != null || detail == null) {
      emit(state.copyWith(status: QuoteFormStatus.failure, message: error));
      return;
    }

    final quote = detail!.quote;
    final settingsResult = await _fetchCompanySettings();
    final vatRate =
        quote?.vatRate ??
        settingsResult.fold((_) => defaultVatRate, (s) => s.vatRate);
    final lines =
        quote?.lines
            .map(
              (l) => QuoteLineDraft(
                productId: l.productId,
                description: l.description,
                widthCm: l.widthCm,
                heightCm: l.heightCm,
                quantity: l.quantity,
                unitPrice: l.unitPrice,
                sortOrder: l.sortOrder,
              ),
            )
            .toList() ??
        [
          const QuoteLineDraft(
            description: '',
            widthCm: 0,
            heightCm: 0,
            quantity: 1,
            unitPrice: 0,
            sortOrder: 0,
          ),
        ];

    emit(
      state.copyWith(
        status: QuoteFormStatus.ready,
        detail: detail,
        products: products,
        specsDescription: quote?.specsDescription ?? '',
        otherComments: quote?.otherComments ?? defaultQuoteOtherCommentsText,
        discountAmount: quote?.resolvedDiscountAmount ?? 0,
        vatRate: vatRate,
        manufacturingDurationDays: quote?.manufacturingDurationDays,
        extraCharges: quote?.extraCharges ?? const [],
        quoteDate: quote?.quoteDate ?? DateTime.now(),
        lines: lines,
        message: null,
      ),
    );
  }

  void _onSpecs(QuoteFormSpecsChanged event, Emitter<QuoteFormState> emit) {
    emit(state.copyWith(specsDescription: event.value));
  }

  void _onComments(
    QuoteFormCommentsChanged event,
    Emitter<QuoteFormState> emit,
  ) {
    emit(state.copyWith(otherComments: event.value));
  }

  void _onDiscount(
    QuoteFormDiscountChanged event,
    Emitter<QuoteFormState> emit,
  ) {
    emit(state.copyWith(discountAmount: event.value));
  }

  void _onDuration(
    QuoteFormDurationChanged event,
    Emitter<QuoteFormState> emit,
  ) {
    emit(
      state.copyWith(
        manufacturingDurationDays: event.value,
        clearDuration: event.value == null,
      ),
    );
  }

  void _onExtras(QuoteFormExtrasChanged event, Emitter<QuoteFormState> emit) {
    emit(state.copyWith(extraCharges: event.charges));
  }

  void _onDateChanged(
    QuoteFormDateChanged event,
    Emitter<QuoteFormState> emit,
  ) {
    emit(state.copyWith(quoteDate: event.value));
  }

  void _onLineAdded(QuoteFormLineAdded event, Emitter<QuoteFormState> emit) {
    final lines = [...state.lines];
    lines.add(
      QuoteLineDraft(
        description: '',
        widthCm: 0,
        heightCm: 0,
        quantity: 1,
        unitPrice: 0,
        sortOrder: lines.length,
      ),
    );
    emit(state.copyWith(lines: lines));
  }

  void _onLineRemoved(
    QuoteFormLineRemoved event,
    Emitter<QuoteFormState> emit,
  ) {
    if (state.lines.length <= 1) return;
    final lines = [...state.lines]..removeAt(event.index);
    emit(
      state.copyWith(
        lines: [
          for (var i = 0; i < lines.length; i++)
            QuoteLineDraft(
              productId: lines[i].productId,
              description: lines[i].description,
              widthCm: lines[i].widthCm,
              heightCm: lines[i].heightCm,
              quantity: lines[i].quantity,
              unitPrice: lines[i].unitPrice,
              sortOrder: i,
            ),
        ],
      ),
    );
  }

  void _onLineUpdated(
    QuoteFormLineUpdated event,
    Emitter<QuoteFormState> emit,
  ) {
    final lines = [...state.lines];
    if (event.index < 0 || event.index >= lines.length) return;
    lines[event.index] = event.line;
    emit(state.copyWith(lines: lines));
  }

  void _onProductPicked(
    QuoteFormProductPicked event,
    Emitter<QuoteFormState> emit,
  ) {
    final lines = [...state.lines];
    if (event.index < 0 || event.index >= lines.length) return;
    final current = lines[event.index];
    lines[event.index] = QuoteLineDraft(
      productId: event.product.id,
      description: event.product.name,
      widthCm: current.widthCm,
      heightCm: current.heightCm,
      quantity: current.quantity,
      unitPrice: event.product.unitPrice,
      sortOrder: current.sortOrder,
    );
    emit(state.copyWith(lines: lines));
  }

  Future<void> _onSubmitted(
    QuoteFormSubmitted event,
    Emitter<QuoteFormState> emit,
  ) async {
    final orderId = state.orderId;
    if (orderId == null) return;

    final draft = QuoteDraft(
      quoteDate: state.quoteDate ?? DateTime.now(),
      specsDescription: state.specsDescription,
      otherComments: state.otherComments,
      discountAmount: state.discountAmount,
      vatRate: state.vatRate,
      manufacturingDurationDays: state.manufacturingDurationDays,
      extraCharges: state.extraCharges,
      status: event.issue
          ? DocumentIssueStatus.issued
          : DocumentIssueStatus.draft,
      lines: state.lines,
    );

    final validation = draft.validationError;
    if (validation != null) {
      dbgWorkOrders('quote validation blocked: $validation');
      emit(state.copyWith(message: validation));
      return;
    }

    emit(state.copyWith(status: QuoteFormStatus.saving, message: null));
    final result = await _saveQuote(orderId: orderId, draft: draft);
    await result.fold(
      (failure) async {
        dbgWorkOrdersError('quote save failed', error: failure.message);
        emit(
          state.copyWith(
            status: QuoteFormStatus.ready,
            message: failure.message,
          ),
        );
      },
      (quote) async {
        dbgWorkOrders('quote saved #${quote.quoteNumber}');
        final detailResult = await _fetchDetail(orderId);
        final detail = detailResult.fold((_) => null, (d) => d);
        if (detail != null && event.sharePdf) {
          try {
            final withWords = CommercialOrderDetail(
              order: detail.order,
              customer: detail.customer,
              factory: detail.factory,
              quote: quote,
              agreement: detail.agreement,
              createdBy: detail.createdBy,
            );
            if (!event.context.mounted) return;
            final bytes = await _quotePdfBuilder.build(
              withWords,
              context: event.context,
            );
            final file = await _pdfShareService.saveBytes(
              bytes: bytes,
              fileName: 'quote-${quote.quoteNumber}.pdf',
            );
            await _pdfShareService.shareFile(
              file: file,
              subject: 'عرض السعر ${quote.quoteNumber}',
            );
          } catch (e, st) {
            dbgWorkOrdersError(
              'quote pdf after save failed',
              error: e,
              stackTrace: st,
            );
          }
        }
        emit(
          state.copyWith(
            status: QuoteFormStatus.success,
            detail: detail,
            message: 'تم حفظ عرض السعر',
          ),
        );
      },
    );
  }
}

sealed class QuoteFormEvent extends Equatable {
  const QuoteFormEvent();
  @override
  List<Object?> get props => [];
}

class QuoteFormStarted extends QuoteFormEvent {
  const QuoteFormStarted(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

class QuoteFormSpecsChanged extends QuoteFormEvent {
  const QuoteFormSpecsChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class QuoteFormCommentsChanged extends QuoteFormEvent {
  const QuoteFormCommentsChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

class QuoteFormDiscountChanged extends QuoteFormEvent {
  const QuoteFormDiscountChanged(this.value);
  final double value;
  @override
  List<Object?> get props => [value];
}

class QuoteFormDurationChanged extends QuoteFormEvent {
  const QuoteFormDurationChanged(this.value);
  final int? value;
  @override
  List<Object?> get props => [value];
}

class QuoteFormExtrasChanged extends QuoteFormEvent {
  const QuoteFormExtrasChanged(this.charges);
  final List<DocumentExtraCharge> charges;
  @override
  List<Object?> get props => [charges];
}

class QuoteFormDateChanged extends QuoteFormEvent {
  const QuoteFormDateChanged(this.value);
  final DateTime value;
  @override
  List<Object?> get props => [value];
}

class QuoteFormLineAdded extends QuoteFormEvent {
  const QuoteFormLineAdded();
}

class QuoteFormLineRemoved extends QuoteFormEvent {
  const QuoteFormLineRemoved(this.index);
  final int index;
  @override
  List<Object?> get props => [index];
}

class QuoteFormLineUpdated extends QuoteFormEvent {
  const QuoteFormLineUpdated(this.index, this.line);
  final int index;
  final QuoteLineDraft line;
  @override
  List<Object?> get props => [index, line];
}

class QuoteFormProductPicked extends QuoteFormEvent {
  const QuoteFormProductPicked(this.index, this.product);
  final int index;
  final Product product;
  @override
  List<Object?> get props => [index, product];
}

class QuoteFormSubmitted extends QuoteFormEvent {
  const QuoteFormSubmitted({
    this.sharePdf = false,
    this.issue = true,
    required this.context,
  });
  final bool sharePdf;
  final bool issue;
  final BuildContext context;
  @override
  List<Object?> get props => [sharePdf, issue];
}

enum QuoteFormStatus { initial, loading, ready, saving, success, failure }

class QuoteFormState extends Equatable {
  const QuoteFormState({
    this.status = QuoteFormStatus.initial,
    this.orderId,
    this.detail,
    this.products = const [],
    this.specsDescription = '',
    this.otherComments = defaultQuoteOtherCommentsText,
    this.discountAmount = 0,
    this.vatRate = defaultVatRate,
    this.manufacturingDurationDays,
    this.extraCharges = const [],
    this.quoteDate,
    this.lines = const [],
    this.message,
  });

  final QuoteFormStatus status;
  final String? orderId;
  final CommercialOrderDetail? detail;
  final List<Product> products;
  final String specsDescription;
  final String otherComments;
  final double discountAmount;
  final double vatRate;
  final int? manufacturingDurationDays;
  final List<DocumentExtraCharge> extraCharges;
  final DateTime? quoteDate;
  final List<QuoteLineDraft> lines;
  final String? message;

  QuoteDraft get draft => QuoteDraft(
    quoteDate: quoteDate ?? DateTime.now(),
    specsDescription: specsDescription,
    otherComments: otherComments,
    discountAmount: discountAmount,
    vatRate: vatRate,
    manufacturingDurationDays: manufacturingDurationDays,
    extraCharges: extraCharges,
    lines: lines,
  );

  QuoteFormState copyWith({
    QuoteFormStatus? status,
    String? orderId,
    CommercialOrderDetail? detail,
    List<Product>? products,
    String? specsDescription,
    String? otherComments,
    double? discountAmount,
    double? vatRate,
    int? manufacturingDurationDays,
    bool clearDuration = false,
    List<DocumentExtraCharge>? extraCharges,
    DateTime? quoteDate,
    List<QuoteLineDraft>? lines,
    String? message,
  }) {
    return QuoteFormState(
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      detail: detail ?? this.detail,
      products: products ?? this.products,
      specsDescription: specsDescription ?? this.specsDescription,
      otherComments: otherComments ?? this.otherComments,
      discountAmount: discountAmount ?? this.discountAmount,
      vatRate: vatRate ?? this.vatRate,
      manufacturingDurationDays: clearDuration
          ? null
          : (manufacturingDurationDays ?? this.manufacturingDurationDays),
      extraCharges: extraCharges ?? this.extraCharges,
      quoteDate: quoteDate ?? this.quoteDate,
      lines: lines ?? this.lines,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    orderId,
    detail,
    products,
    specsDescription,
    otherComments,
    discountAmount,
    vatRate,
    manufacturingDurationDays,
    extraCharges,
    quoteDate,
    lines,
    message,
  ];
}
