import '../../domain/entities/local_media_pick.dart';
import '../../domain/entities/paged_result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_media_storage_data_source.dart';
import '../datasources/products_remote_data_source.dart';
import '../datasources/storage_settings_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(
    this._remote,
    this._storageSettings,
    this._mediaStorage,
  );

  final ProductsRemoteDataSource _remote;
  final StorageSettingsRemoteDataSource _storageSettings;
  final ProductMediaStorageDataSource _mediaStorage;

  @override
  Future<PagedResult<Product>> fetchProductsPage({
    required int page,
    int pageSize = productsPageSize,
  }) {
    return _remote.fetchProductsPage(page: page, pageSize: pageSize);
  }

  @override
  Future<Product> createProduct(ProductDraft draft) async {
    final quota = await _storageSettings.fetchStorageQuota();
    return _remote.createProduct(draft, quota: quota);
  }

  @override
  Future<Product> updateProduct({
    required String productId,
    required ProductDraft draft,
    required Product baseline,
  }) async {
    final quota = await _storageSettings.fetchStorageQuota();
    return _remote.updateProduct(
      productId,
      draft,
      quota: quota,
      baseline: baseline,
    );
  }

  @override
  Future<Product> fetchProductById(String productId) {
    return _remote.fetchProductById(productId);
  }

  @override
  Future<Product> appendProductImage({
    required String productId,
    required LocalMediaPick pick,
  }) async {
    final quota = await _storageSettings.fetchStorageQuota();
    return _remote.appendProductImage(
      productId: productId,
      pick: pick,
      quota: quota,
    );
  }

  @override
  Future<Product> appendColorImage({
    required String productId,
    required String colorId,
    required LocalMediaPick pick,
  }) async {
    final quota = await _storageSettings.fetchStorageQuota();
    return _remote.appendColorImage(
      productId: productId,
      colorId: colorId,
      pick: pick,
      quota: quota,
    );
  }

  @override
  Future<String> uploadPublicMedia({
    required String folder,
    required LocalMediaPick pick,
  }) async {
    final path = await _mediaStorage.uploadLooseImage(
      folder: folder,
      pick: pick,
    );
    return _mediaStorage.publicUrl(path);
  }
}
