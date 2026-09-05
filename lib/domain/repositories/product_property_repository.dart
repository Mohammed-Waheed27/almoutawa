import '../entities/product_property.dart';

abstract class ProductPropertyRepository {
  Future<List<ProductPropertyDefinition>> fetchDefinitions();

  Future<ProductPropertyDefinition> createDefinition(
    ProductPropertyDefinitionDraft draft,
  );

  Future<ProductPropertyDefinition> updateDefinition(
    String definitionId,
    ProductPropertyDefinitionDraft draft,
  );
}
