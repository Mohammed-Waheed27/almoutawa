part of 'property_definitions_list_bloc.dart';

abstract class PropertyDefinitionsListEvent extends Equatable {
  const PropertyDefinitionsListEvent();

  @override
  List<Object?> get props => [];
}

class PropertyDefinitionsListStarted extends PropertyDefinitionsListEvent {
  const PropertyDefinitionsListStarted();
}

class PropertyDefinitionsListRefreshRequested
    extends PropertyDefinitionsListEvent {
  const PropertyDefinitionsListRefreshRequested();
}

class PropertyDefinitionsListSearchChanged
    extends PropertyDefinitionsListEvent {
  const PropertyDefinitionsListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
