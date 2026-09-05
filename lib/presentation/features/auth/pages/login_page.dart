import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/layout/adaptive_content_frame.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/shared/widgets/buttons/almoutawa_button.dart';
import '../../../../core/shared/widgets/feedback/almoutawa_snackbar.dart';
import '../../../../core/shared/widgets/inputs/almoutawa_text_field.dart';
import '../../../../core/shared/widgets/layout/auth_form_card.dart';
import '../../../../core/shared/widgets/layout/hub_greeting.dart';
import '../../../../core/shared/widgets/navigation/navigation.dart';
import '../../../../l10n/app_strings.dart';
import '../../../widgets/role_dashboard_scaffold.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoleDashboardScaffold(
      appBarMode: AlmoutawaAppBarMode.none,
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.message != current.message,
        listener: (context, state) {
          if (state.status == AuthStatus.failure && state.message != null) {
            AlmoutawaSnackbar.show(context, state.message!);
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.containerPadding),
            child: AdaptiveContentFrame(
              mode: AdaptiveContentMode.auth,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: AppSpacing.xxl),
                    const AuthHeroHeader(
                      showLogo: true,
                      subtitle: AppStrings.appTagline,
                    ),
                    SizedBox(height: AppSpacing.xxl),
                    AuthFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthHeroHeader(
                            title: 'تسجيل الدخول',
                            subtitle: 'أدخل بيانات حسابك للمتابعة',
                          ),
                          SizedBox(height: AppSpacing.xl),
                          AlmoutawaTextField(
                            controller: _emailController,
                            label: 'البريد الإلكتروني',
                            hint: 'name@company.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'مطلوب' : null,
                          ),
                          SizedBox(height: AppSpacing.lg),
                          AlmoutawaTextField(
                            controller: _passwordController,
                            label: 'كلمة المرور',
                            hint: 'أدخل كلمة المرور',
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'مطلوب' : null,
                          ),
                          SizedBox(height: AppSpacing.xl),
                          AlmoutawaButton(
                            label: isLoading ? 'جاري الدخول...' : 'دخول',
                            icon: Icons.login_rounded,
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }
                                    context.read<AuthBloc>().add(
                                      AuthSignInRequested(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      ),
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
