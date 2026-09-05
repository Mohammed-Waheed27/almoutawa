import 'package:flutter/foundation.dart';

import '../features/auth/bloc/auth_bloc.dart';

/// Bridges [AuthBloc] state changes to GoRouter refresh.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(this._authBloc) {
    _authBloc.stream.listen((_) => notifyListeners());
  }

  final AuthBloc _authBloc;
}
