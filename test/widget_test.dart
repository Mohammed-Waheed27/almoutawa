import 'package:flutter_test/flutter_test.dart';

import 'package:almoutawa/domain/entities/user_role.dart';

void main() {
  test('delivery worker role maps from database value', () {
    expect(UserRole.fromDbValue('delivery_worker'), UserRole.deliveryWorker);
    expect(UserRole.deliveryWorker.arabicLabel, 'مندوب تسليم');
    expect(UserRole.deliveryWorker.routeName, 'delivery');
  });
}
