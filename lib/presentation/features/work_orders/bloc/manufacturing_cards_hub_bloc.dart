import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/debug/debug_flow_logs.dart';
import '../../../../domain/entities/commercial_order.dart';
import '../../../../domain/entities/manufacturing_card.dart';
import '../../../../domain/usecases/commercial_order_usecases.dart';

class ManufacturingCardsHubBloc
    extends Bloc<ManufacturingCardsHubEvent, ManufacturingCardsHubState> {
  ManufacturingCardsHubBloc({
    required FetchCommercialOrderDetailUseCase fetchDetail,
    required FetchManufacturingCardsUseCase fetchCards,
  }) : _fetchDetail = fetchDetail,
       _fetchCards = fetchCards,
       super(const ManufacturingCardsHubState()) {
    on<ManufacturingCardsHubStarted>(_onStarted);
    on<ManufacturingCardsHubRefreshed>(_onRefreshed);
    on<ManufacturingCardsHubCardSaved>(_onCardSaved);
  }

  final FetchCommercialOrderDetailUseCase _fetchDetail;
  final FetchManufacturingCardsUseCase _fetchCards;

  Future<void> _onStarted(
    ManufacturingCardsHubStarted event,
    Emitter<ManufacturingCardsHubState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ManufacturingCardsHubStatus.loading,
        orderId: event.orderId,
      ),
    );
    await _load(event.orderId, emit);
  }

  Future<void> _onRefreshed(
    ManufacturingCardsHubRefreshed event,
    Emitter<ManufacturingCardsHubState> emit,
  ) async {
    final orderId = state.orderId;
    if (orderId == null) return;
    await _load(orderId, emit);
  }

  void _onCardSaved(
    ManufacturingCardsHubCardSaved event,
    Emitter<ManufacturingCardsHubState> emit,
  ) {
    final cards = [...state.cards];
    final idx = cards.indexWhere((c) => c.id == event.card.id);
    if (idx >= 0) {
      cards[idx] = event.card;
    } else {
      cards.add(event.card);
    }
    final slots = _buildSlots(state.detail, cards);
    emit(state.copyWith(cards: cards, slots: slots));
  }

  Future<void> _load(
    String orderId,
    Emitter<ManufacturingCardsHubState> emit,
  ) async {
    final detailResult = await _fetchDetail(orderId);
    final cardsResult = await _fetchCards(orderId);

    CommercialOrderDetail? detail;
    List<ManufacturingCard> cards = const [];
    String? error;

    detailResult.fold((f) => error = f.message, (v) => detail = v);
    cardsResult.fold(
      (f) => error ??= f.message,
      (v) => cards = v,
    );

    if (error != null || detail == null) {
      dbgWorkOrdersError('hub load failed', error: error);
      emit(
        state.copyWith(
          status: ManufacturingCardsHubStatus.failure,
          message: error,
        ),
      );
      return;
    }

    final slots = _buildSlots(detail, cards);
    final completed = slots.where((s) => s.isComplete).length;
    dbgWorkOrders(
      'hub loaded orderId=$orderId slots=${slots.length} completed=$completed',
    );

    emit(
      state.copyWith(
        status: ManufacturingCardsHubStatus.ready,
        detail: detail,
        cards: cards,
        slots: slots,
        message: null,
      ),
    );
  }

  List<ManufacturingCardSlot> _buildSlots(
    CommercialOrderDetail? detail,
    List<ManufacturingCard> cards,
  ) {
    final agreement = detail?.agreement;
    if (agreement == null) return const [];
    return buildManufacturingCardSlots(agreement: agreement, cards: cards);
  }
}

sealed class ManufacturingCardsHubEvent extends Equatable {
  const ManufacturingCardsHubEvent();
  @override
  List<Object?> get props => [];
}

class ManufacturingCardsHubStarted extends ManufacturingCardsHubEvent {
  const ManufacturingCardsHubStarted(this.orderId);
  final String orderId;
  @override
  List<Object?> get props => [orderId];
}

class ManufacturingCardsHubRefreshed extends ManufacturingCardsHubEvent {
  const ManufacturingCardsHubRefreshed();
}

class ManufacturingCardsHubCardSaved extends ManufacturingCardsHubEvent {
  const ManufacturingCardsHubCardSaved(this.card);
  final ManufacturingCard card;
  @override
  List<Object?> get props => [card];
}

enum ManufacturingCardsHubStatus { initial, loading, ready, failure }

class ManufacturingCardsHubState extends Equatable {
  const ManufacturingCardsHubState({
    this.status = ManufacturingCardsHubStatus.initial,
    this.orderId,
    this.detail,
    this.cards = const [],
    this.slots = const [],
    this.message,
  });

  final ManufacturingCardsHubStatus status;
  final String? orderId;
  final CommercialOrderDetail? detail;
  final List<ManufacturingCard> cards;
  final List<ManufacturingCardSlot> slots;
  final String? message;

  bool get showBlockingSpinner =>
      (status == ManufacturingCardsHubStatus.loading ||
          status == ManufacturingCardsHubStatus.initial) &&
      slots.isEmpty;

  int get completedCount => slots.where((s) => s.isComplete).length;
  int get totalCount => slots.length;
  bool get cardsLocked => detail?.order.phase.isFinished ?? false;

  ManufacturingCardsHubState copyWith({
    ManufacturingCardsHubStatus? status,
    String? orderId,
    CommercialOrderDetail? detail,
    List<ManufacturingCard>? cards,
    List<ManufacturingCardSlot>? slots,
    String? message,
  }) {
    return ManufacturingCardsHubState(
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      detail: detail ?? this.detail,
      cards: cards ?? this.cards,
      slots: slots ?? this.slots,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, orderId, detail, cards, slots, message];
}
