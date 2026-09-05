import '../entities/local_media_pick.dart';
import '../entities/paged_result.dart';
import '../entities/product.dart';

const productsPageSize = 20;

abstract class ProductRepository {
  Future<PagedResult<Product>> fetchProductsPage({
    required int page,
    int pageSize = productsPageSize,
  });

  Future<Product> createProduct(ProductDraft draft);

  Future<Product> updateProduct({
    required String productId,
    required ProductDraft draft,
    required Product baseline,
  });

  Future<Product> fetchProductById(String productId);

  Future<Product> appendProductImage({
    required String productId,
    required LocalMediaPick pick,
  });

  Future<Product> appendColorImage({
    required String productId,
    required String colorId,
    required LocalMediaPick pick,
  });

  Future<String> uploadPublicMedia({
    required String folder,
    required LocalMediaPick pick,
  });
}
