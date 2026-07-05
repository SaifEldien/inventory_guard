import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/.env');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthCubit>(),
      child: MaterialApp(
        title: 'Inventory Guard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) => 
            current is Authenticated || current is Unauthenticated || current is AuthInitial,
          builder: (context, state) {
            if (state is Authenticated) {
              return const MainNavigationScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
