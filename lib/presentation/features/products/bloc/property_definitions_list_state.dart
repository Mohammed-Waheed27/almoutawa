part of 'property_definitions_list_bloc.dart';

enum PropertyDefinitionsListStatus { initial, loading, success, failure }

class PropertyDefinitionsListState extends Equatable {
  const PropertyDefinitionsListState({
    this.status = PropertyDefinitionsListStatus.initial,
    this.definitions = const [],
    this.searchQuery = '',
    this.message,
  });

  final PropertyDefinitionsListStatus status;
  final List<ProductPropertyDefinition> definitions;
  final String searchQuery;
  final String? message;

  bool get showBlockingSpinner =>
      status == PropertyDefinitionsListStatus.loading && definitions.isEmpty;

  List<ProductPropertyDefinition> get filteredDefinitions {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return definitions;
    return definitions
        .where(
          (item) =>
              item.nameAr.toLowerCase().contains(query) ||
              item.nameEn.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  PropertyDefinitionsListState copyWith({
    PropertyDefinitionsListStatus? status,
    List<ProductPropertyDefinition>? definitions,
    String? searchQuery,
    String? message,
    bool clearMessage = false,
  }) {
    return PropertyDefinitionsListState(
      status: status ?? this.status,
      definitions: definitions ?? this.definitions,
      searchQuery: searchQuery ?? this.searchQuery,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, definitions, searchQuery, message];
}
