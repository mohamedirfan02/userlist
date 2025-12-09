
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:userlist/core/constant/app_hive_storage_constants.dart';
import 'package:userlist/data/repositories/auth_repository.dart';
import 'package:userlist/models/address_model.dart';
import 'package:userlist/views/address_detail_screen.dart';
import 'package:userlist/views/splash_screen.dart';
import 'package:userlist/viewmodels/address_viewmodel.dart';
import 'package:userlist/viewmodels/auth_viewmodel.dart';
import 'firebase_options.dart';
import 'package:userlist/views/login_screen.dart';
import 'package:userlist/views/address_list_screen.dart';
import 'package:userlist/views/add_address_screen.dart';
import 'package:userlist/views/edit_address_screen.dart';

/// The entry point of the application.
void main() async {
  // Ensures that the Flutter binding is initialized before any Flutter code is executed.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  // This is included to show how it would be done in a real app, but it's not
  // strictly necessary for this example since we are not using Firebase Phone Auth.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization skipped: $e');
  }

  // ✅ Initialize Hive
  await Hive.initFlutter();

  // ✅ Open boxes before app starts
  await Hive.openBox(AppHiveStorageConstants.authBoxKey);
  await Hive.openBox(AppHiveStorageConstants.addressBoxKey);

  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // [MultiProvider] makes the view models available to the entire widget tree.
    return MultiProvider(
      providers: [
        // Provides the [AuthViewModel] to the widget tree.
        ChangeNotifierProvider(
          create: (_) {
            final vm = AuthViewModel(AuthRepository());
            vm.initAuthState(); // ✅ Load stored state from Hive
            return vm;
          },
        ),
        // Provides the [AddressViewModel] to the widget tree.
        ChangeNotifierProvider(create: (_) => AddressViewModel()),
      ],
      child: MaterialApp(
        title: 'Address Manager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,

          // Use Google Fonts globally
          textTheme: GoogleFonts.robotoTextTheme(
            Theme.of(context).textTheme,
          ),

          // Optionally, also apply Google Fonts to the app bar and other components
          appBarTheme: AppBarTheme(
            titleTextStyle: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        // The initial route of the application.
        initialRoute: '/', // Start with the SplashScreen

        // The [onGenerateRoute] callback is used to handle named routes.
        // This allows for custom page transitions and passing arguments between routes.
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return _buildPageRoute(const SplashScreen(), settings);
            case '/login':
              return _buildPageRoute(const LoginScreen(), settings);
            case '/address-list':
              return _buildPageRoute(const AddressListScreen(), settings);
            case '/add-address':
              return _buildPageRoute(const AddAddressScreen(), settings);
            case '/edit-address':
              return _buildPageRoute(const EditAddressScreen(), settings);
            case '/address-detail':
              // Extracts the [Address] object from the route arguments.
              final address = settings.arguments as Address;
              return _buildPageRoute(AddressDetailScreen(address: address), settings);
            default:
              // If the route is not recognized, default to the SplashScreen.
              return _buildPageRoute(const SplashScreen(), settings);
          }
        },
      ),
    );
  }

  /// A helper method to create a [PageRoute] with a custom slide transition.
  PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide from the right
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
