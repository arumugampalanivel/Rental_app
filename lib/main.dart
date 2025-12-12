import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tenant_list_screen.dart';
import 'screens/tenant_registration_screen.dart';
import 'screens/company_details_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/tenant_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/edit_company_screen.dart';
import 'screens/edit_room_screen.dart';
import 'screens/add_rent_screen.dart';
import 'screens/rent_history_screen.dart';
import 'screens/edit_personal_screen.dart';
import 'screens/add_room_screen.dart';
import 'screens/room_details_building_screen.dart';
import '../models/room_model.dart';
import 'screens/edit_room_building_screen.dart';
import 'screens/rooms_screen.dart';
import 'screens/all_rent_history_screen.dart';
import 'screens/room_details_screen.dart';

// <- THIS is required for join()

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //String path = join(await getDatabasesPath(), 'rent_manager.db');
  //await deleteDatabase(path);
  //print('DB path: $path');

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const RentManagerApp());
}

class RentManagerApp extends StatelessWidget {
  const RentManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Rent Manager',
      theme: ThemeData(primarySwatch: Colors.teal),

      // Home screen
      home: const LoginScreen(),

      // Use onGenerateRoute for dynamic routes
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/tenant-list':
            return MaterialPageRoute(builder: (_) => const TenantListScreen());

          case '/tenant-registration':
            return MaterialPageRoute(
              builder: (_) => TenantRegistrationScreen(),
            );

          case '/company-details':
            return MaterialPageRoute(
              builder: (_) => const CompanyDetailsScreen(),
              settings: settings,
            );

          case '/rooms':
            return MaterialPageRoute(builder: (_) => const RoomsScreen());

          case '/room-details':
            return MaterialPageRoute(
              builder: (_) => const RoomDetailsScreen(),
              settings: settings,
            );

          case '/add-room':
            return MaterialPageRoute<bool>(
              builder: (_) => const AddRoomScreen(),
            );

          case RoomDetailsBuildingScreen.routeName:
            final room = settings.arguments as RoomModel;
            return MaterialPageRoute<bool>(
              builder: (_) => RoomDetailsBuildingScreen(),
              settings: RouteSettings(arguments: room),
            );

          case EditRoomBuildingScreen.routeName:
            final room = settings.arguments as RoomModel;
            return MaterialPageRoute<bool>(
              builder: (_) => const EditRoomBuildingScreen(),
              settings: RouteSettings(arguments: room),
            );

          case '/summary':
            return MaterialPageRoute(
              builder: (_) => SummaryScreen(),
              settings: settings,
            );

          case '/payment-history':
            return MaterialPageRoute(
              builder: (_) => const AllRentHistoryScreen(),
            );

          case '/dashboard': // ADD THIS
            return MaterialPageRoute(builder: (_) => DashboardScreen());

          /// ✅ FIXED: Route for Tenant Profile
          case '/tenant-profile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => TenantProfileScreen(tenantId: args['tenantId']),
            );

          case '/edit-company':
            return MaterialPageRoute(
              builder: (_) => const EditCompanyScreen(),
              settings: settings,
            );

          case '/edit-room':
            return MaterialPageRoute(
              builder: (_) => const EditRoomScreen(),
              settings: settings,
            );

          case '/edit-personal':
            return MaterialPageRoute(
              builder: (_) => const EditPersonalScreen(),
              settings: settings,
            );

          case '/add-rent':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AddRentScreen(tenantId: args['tenantId']),
            );

          case RentHistoryScreen.routeName:
            final tenantId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => const RentHistoryScreen(),
              settings: RouteSettings(arguments: tenantId),
            );

          case '/rent-update-flow':
            // Open tenant list for selecting a tenant first
            return MaterialPageRoute(
              builder: (_) =>
                  const TenantListScreen(isSelectingForRentUpdate: true),
            );
        }

        return null; // fallback
      },
    );
  }
}
