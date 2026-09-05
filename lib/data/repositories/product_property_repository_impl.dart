import '../../domain/entities/product_property.dart';
import '../../domain/repositories/product_property_repository.dart';
import '../datasources/product_properties_remote_data_source.dart';

class ProductPropertyRepositoryImpl implements ProductPropertyRepository {
  ProductPropertyRepositoryImpl(this._remote);

  final ProductPropertiesRemoteDataSource _remote;

  @override
  Future<List<ProductPropertyDefinition>> fetchDefinitions() {
    return _remote.fetchDefinitions();
  }

  @override
  Future<ProductPropertyDefinition> createDefinition(
    ProductPropertyDefinitionDraft draft,
  ) {
    return _remote.createDefinition(draft);
  }

  @override
  Future<ProductPropertyDefinition> updateDefinition(
    String definitionId,
    ProductPropertyDefinitionDraft draft,
  ) {
    return _remote.updateDefinition(definitionId, draft);
  }
}
