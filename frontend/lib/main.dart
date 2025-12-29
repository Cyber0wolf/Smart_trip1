import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'feature/auth/bloc/auth_bloc.dart';
import 'feature/auth/data/auth_api.dart';
import 'core/network/api_client.dart';
import 'feature/auth/presentation/login_page.dart';
import 'shared/routes/app_routes.dart';
import 'shared/auth/auth_gate.dart';
import 'feature/home/presentation/home_page.dart';
import 'feature/profile/presentation/account_page.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return BlocProvider(
      create: (_) => AuthBloc(
        AuthApi(apiClient),
        apiClient,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.trips: (_) => AuthGate(child: const HomePage()),
          AppRoutes.account: (_) => AuthGate(child: const AccountPage()),
        },
      ),
    );
  }
}
