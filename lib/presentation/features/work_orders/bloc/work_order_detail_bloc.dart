import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../core/pdf/agreement_pdf_builder.dart';
import '../../../../core/pdf/pdf_document_action.dart';
import '../../../../core/pdf/pdf_share_service.dart';
import '../../../../core/pdf/quote_pdf_builder.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/factory_profile.dart';
import '../../../../domain/usecases/commercial_order_usecases.dart';

class WorkOrderDetailBloc
    extends Bloc<WorkOrderDetailEvent, WorkOrderDetailState> {
  WorkOrderDetailBloc({
    required FetchCommercialOrderDetailUseCase fetchDetail,
    required FetchManufacturingCardsUseCase fetchManufacturingCards,
    required FetchFactoriesUseCase fetchFactories,
    required AdvanceCommercialOrderPhaseUseCase advancePhase,
    required AssignCommercialOrderFactoryUseCase assignFactory,
    required QuotePdfBuilder quotePdfBuilder,
    required AgreementPdfBuilder agreementPdfBuilder,
    required PdfShareService pdfShareService,
  }) : _fetchDetail = fetchDetail,
       _fetchManufacturingCards = fetchManufacturingCards,
       _fetchFactories = fetchFactories,
       _advancePhase = advancePhase,
       _assignFactory = assignFactory,
       _quotePdfBuilder = quotePdfBuilder,
       _agreementPdfBuilder = agreementPdfBuilder,
       _pdfShareService = pdfShareService,
       super(const WorkOrderDetailState()) {
    on<WorkOrderDetailStarted>(_onStarted);
    on<WorkOrderDetailRefreshRequested>(_onRefresh);
    on<WorkOrderDetailQuotePdfRequested>(_onQuotePdf);
    on<WorkOrderDetailAgreementPdfRequested>(_onAgreementPdf);
    on<WorkOrderDetailFactoryAssigned>(_onFactoryAssigned);
    on<WorkOrderDetailPhaseAdvanceRequested>(_onPhaseAdvance);
  }

  final FetchCommercialOrderDetailUseCase _fetchDetail;
  final FetchManufacturingCardsUseCase _fetchManufacturingCards;
  final FetchFactoriesUseCase _fetchFactories;
  final AdvanceCommercialOrderPhaseUseCase _advancePhase;
  final AssignCommercialOrderFactoryUseCase _assignFactory;
  final QuotePdfBuilder _quotePdfBuilder;
  final AgreementPdfBuilder _agreementPdfBuilder;
  final PdfShareService _pdfShareService;

  Future<void> _onStarted(
    WorkOrderDetailStarted event,
    Emitter<WorkOrderDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        status: WorkOrderDetailStatus.loading,
        orderId: event.orderId,
        loadOpsControls: event.loadOpsControls,
      ),
    );
    await _load(event.orderId, emit, loadFactories: event.loadOpsControls);
  }

  Future<void> _onRefresh(
    WorkOrderDetailRefreshRequested event,
    Emitter<WorkOrderDetailState> emit,
  ) async {
    final id = state.orderId;
    if (id == null) return;
    await _load(id, emit, loadFactories: state.loadOpsControls);
  }

  Future<void> _load(
    String orderId,
    Emitter<WorkOrderDetailState> emit, {
    required bool loadFactories,
  }) async {
    final result = await _fetchDetail(orderId);
    await result.fold(
      (failure) async {
        dbgWorkOrdersError('detail failed', error: failure.message);
        emit(
          state.copyWith(
            status: WorkOrderDetailStatus.failure,
            message: failure.message,
          ),
        );
      },
      (detail) async {
        dbgWorkOrders('detail ok order=${detail.order.orderNumber}');
        var cardsDone = 0;
        if (detail.agreement != null) {
          final cardsResult = await _fetchManufacturingCards(orderId);
          cardsResult.fold(
            (f) => dbgWorkOrdersError(
              'detail cards count failed',
              error: f.message,
            ),
            (cards) => cardsDone = cards.length,
          );
        }

        var factories = state.factories;
        if (loadFactories && factories.isEmpty) {
          final factoriesResult = await _fetchFactories();
          factoriesResult.fold(
            (f) =>
                dbgWorkOrdersError('detail factories failed', error: f.message),
            (list) => factories = list,
          );
        }

        emit(
          state.copyWith(
            status: WorkOrderDetailStatus.success,
            detail: detail,
            factories: factories,
            manufacturingCardsDone: cardsDone,
            message: null,
            busyAction: false,
          ),
        );
      },
    );
  }

  Future<void> _onFactoryAssigned(
    WorkOrderDetailFactoryAssigned event,
    Emitter<WorkOrderDetailState> emit,
  ) async {
    final orderId = state.orderId;
    if (orderId == null) return;
    emit(state.copyWith(busyAction: true, message: null));
    dbgWorkOrders('ops assign factory id=${event.factoryId}');
    final result = await _assignFactory(
      orderId: orderId,
      factoryId: event.factoryId,
    );
    result.fold(
      (failure) {
        dbgWorkOrdersError('assign factory failed', error: failure.message);
        emit(state.copyWith(busyAction: false, message: failure.message));
      },
      (detail) {
        dbgWorkOrders('assign factory ok');
        emit(
          state.copyWith(
            busyAction: false,
            detail: detail,
            message: 'تم تعيين المصنع',
          ),
        );
      },
    );
  }

  Future<void> _onPhaseAdvance(
    WorkOrderDetailPhaseAdvanceRequested event,
    Emitter<WorkOrderDetailState> emit,
  ) async {
    final orderId = state.orderId;
    final detail = state.detail;
    if (orderId == null || detail == null) return;

    if (event.phase == CommercialOrderPhase.manufacturing &&
        detail.order.factoryId == null) {
      emit(state.copyWith(message: 'عيّن المصنع قبل بدء التصنيع'));
      return;
    }

    emit(state.copyWith(busyAction: true, message: null));
    dbgWorkOrders('ops advance phase=${event.phase.dbValue}');
    final result = await _advancePhase(orderId: orderId, phase: event.phase);
    await result.fold(
      (failure) async {
        dbgWorkOrdersError('advance phase failed', error: failure.message);
        emit(state.copyWith(busyAction: false, message: failure.message));
      },
      (_) async {
        final reload = await _fetchDetail(orderId);
        reload.fold(
          (failure) =>
              emit(state.copyWith(busyAction: false, message: failure.message)),
          (updated) {
            final message = switch (event.phase) {
              CommercialOrderPhase.manufacturing => 'تم إرسال طلب التصنيع',
              CommercialOrderPhase.completed => 'تم تأكيد إنجاز التصنيع',
              CommercialOrderPhase.delivered => 'تم تأكيد التسليم',
              CommercialOrderPhase.cancelled => 'تم إلغاء الطلب',
              _ => 'تم تحديث حالة الطلب',
            };
            dbgWorkOrders('advance phase ok → ${event.phase.dbValue}');
            emit(
              state.copyWith(
                busyAction: false,
                detail: updated,
                message: message,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onQuotePdf(
    WorkOrderDetailQuotePdfRequested event,
    Emitter<WorkOrderDetailState> emit,
  ) async {
    final detail = state.detail;
    if (detail?.quote == null) {
      emit(state.copyWith(message: 'احفظ عرض السعر أولاً'));
      return;
    }
    emit(state.copyWith(busyPdf: true, message: null));
    try {
      final bytes = await _quotePdfBuilder.build(
        detail!,
        context: event.context,
      );
      final message = await _deliver(
        bytes: bytes,
        fileName: 'quote-${detail.quote!.quoteNumber}.pdf',
        subject: 'عرض السعر #${detail.quote!.quoteNumber}',
        action: event.action,
        detail: detail,
        documentLabel: 'عرض السعر',
      );
      emit(state.copyWith(busyPdf: false, message: message));
    } catch (e, st) {
      dbgWorkOrdersError('quote pdf failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          busyPdf: false,
          message: e is StateError ? e.message : 'تعذر إنشاء PDF عرض السعر',
        ),
      );
    }
  }

  Future<void> _onAgreementPdf(
    WorkOrderDetailAgreementPdfRequested event,
    Emitter<WorkOrderDetailState> emit,
  ) async {
    final detail = state.detail;
    if (detail?.agreement == null) {
      emit(state.copyWith(message: 'احفظ الاتفاقية أولاً'));
      return;
    }
    emit(state.copyWith(busyPdf: true, message: null));
    try {
      final bytes = await _agreementPdfBuilder.build(
        detail!,
        context: event.context,
      );
      final message = await _deliver(
        bytes: bytes,
        fileName: 'agreement-${detail.agreement!.agreementNumber}.pdf',
        subject: 'اتفاقية عمل #${detail.agreement!.agreementNumber}',
        action: event.action,
        detail: detail,
        documentLabel: 'الاتفاقية',
      );
      emit(state.copyWith(busyPdf: false, message: message));
    } catch (e, st) {
      dbgWorkOrdersError('agreement pdf failed', error: e, stackTrace: st);
      emit(
        state.copyWith(
          busyPdf: false,
          message: e is StateError ? e.message : 'تعذر إنشاء PDF الاتفاقية',
        ),
      );
    }
  }

  Future<String> _deliver({
    required Uint8List bytes,
    required String fileName,
    required String subject,
    required PdfDocumentAction action,
    required CommercialOrderDetail detail,
    required String documentLabel,
  }) {
    final clientName = detail.customer.displayName;
    final whatsAppMessage =
        'مرحباً $clientName، نرسل لكم $documentLabel من المطاوعة.';
    return _pdfShareService.deliver(
      bytes: bytes,
      fileName: fileName,
      subject: subject,
      action: action,
      clientPhone: detail.customer.phone,
      whatsAppMessage: whatsAppMessage,
    );
  }
}

sealed class WorkOrderDetailEvent extends Equatable {
  const WorkOrderDetailEvent();
  @override
  List<Object?> get props => [];
}

class WorkOrderDetailStarted extends WorkOrderDetailEvent {
  const WorkOrderDetailStarted(this.orderId, {this.loadOpsControls = false});
  final String orderId;
  final bool loadOpsControls;
  @override
  List<Object?> get props => [orderId, loadOpsControls];
}

class WorkOrderDetailRefreshRequested extends WorkOrderDetailEvent {
  const WorkOrderDetailRefreshRequested();
}

class WorkOrderDetailFactoryAssigned extends WorkOrderDetailEvent {
  const WorkOrderDetailFactoryAssigned(this.factoryId);
  final String factoryId;
  @override
  List<Object?> get props => [factoryId];
}

class WorkOrderDetailPhaseAdvanceRequested extends WorkOrderDetailEvent {
  const WorkOrderDetailPhaseAdvanceRequested(this.phase);
  final CommercialOrderPhase phase;
  @override
  List<Object?> get props => [phase];
}

class WorkOrderDetailQuotePdfRequested extends WorkOrderDetailEvent {
  const WorkOrderDetailQuotePdfRequested(this.action, {required this.context});
  final PdfDocumentAction action;
  final BuildContext context;
  @override
  List<Object?> get props => [action];
}

class WorkOrderDetailAgreementPdfRequested extends WorkOrderDetailEvent {
  const WorkOrderDetailAgreementPdfRequested(
    this.action, {
    required this.context,
  });
  final PdfDocumentAction action;
  final BuildContext context;
  @override
  List<Object?> get props => [action];
}

enum WorkOrderDetailStatus { initial, loading, success, failure }

class WorkOrderDetailState extends Equatable {
  const WorkOrderDetailState({
    this.status = WorkOrderDetailStatus.initial,
    this.orderId,
    this.detail,
    this.factories = const [],
    this.manufacturingCardsDone,
    this.message,
    this.busyPdf = false,
    this.busyAction = false,
    this.loadOpsControls = false,
  });

  final WorkOrderDetailStatus status;
  final String? orderId;
  final CommercialOrderDetail? detail;
  final List<FactoryProfile> factories;
  final int? manufacturingCardsDone;
  final String? message;
  final bool busyPdf;
  final bool busyAction;
  final bool loadOpsControls;

  WorkOrderDetailState copyWith({
    WorkOrderDetailStatus? status,
    String? orderId,
    CommercialOrderDetail? detail,
    List<FactoryProfile>? factories,
    int? manufacturingCardsDone,
    bool clearManufacturingCardsDone = false,
    String? message,
    bool? busyPdf,
    bool? busyAction,
    bool? loadOpsControls,
  }) {
    return WorkOrderDetailState(
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      detail: detail ?? this.detail,
      factories: factories ?? this.factories,
      manufacturingCardsDone: clearManufacturingCardsDone
          ? null
          : (manufacturingCardsDone ?? this.manufacturingCardsDone),
      message: message,
      busyPdf: busyPdf ?? this.busyPdf,
      busyAction: busyAction ?? this.busyAction,
      loadOpsControls: loadOpsControls ?? this.loadOpsControls,
    );
  }

  @override
  List<Object?> get props => [
    status,
    orderId,
    detail,
    factories,
    manufacturingCardsDone,
    message,
    busyPdf,
    busyAction,
    loadOpsControls,
  ];
}
