import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/database/database_helper.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/admin/employee_management_screen.dart';
import 'presentation/screens/admin/add_edit_employee_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  final databaseHelper = DatabaseHelper();
  await databaseHelper.database;
  
  // Initialize repositories
  final authRepository = AuthRepository(databaseHelper: databaseHelper);
  
  // Check if user is already logged in
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt('user_id');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        // Add other providers here as needed
      ],
      child: HRManagementApp(isLoggedIn: userId != null),
    ),
  );
}

class HRManagementApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const HRManagementApp({
    Key? key,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: isLoggedIn ? '/' : '/login',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),
        '/admin/employee_management': (context) => const EmployeeManagementScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/admin/add_edit_employee') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => AddEditEmployeeScreen(
              employee: args?['employee'],
            ),
          );
        }
        return null;
      },
    );
  }
}
