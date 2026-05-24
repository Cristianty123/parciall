import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/services_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/reviews_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/chat/chat_detail_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/map_screen.dart';
import 'screens/home/search_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/reviews_screen.dart';
import 'screens/services/create_service_screen.dart';
import 'screens/services/my_services_screen.dart';
import 'screens/services/service_detail_screen.dart';
import 'theme/app_theme.dart';
import 'models/service_model.dart';
=======
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/auth/register_screen.dart';
import 'ui/screens/auth/welcome_screen.dart';
import 'ui/screens/chat/chat_detail_screen.dart';
import 'ui/screens/chat/chat_list_screen.dart';
import 'ui/screens/home/home_screen.dart';
import 'ui/screens/home/map_screen.dart';
import 'ui/screens/home/search_screen.dart';
import 'ui/screens/profile/edit_profile_screen.dart';
import 'ui/screens/profile/profile_screen.dart';
import 'ui/screens/profile/reviews_screen.dart';
import 'ui/screens/services/create_service_screen.dart';
import 'ui/screens/services/my_services_screen.dart';
import 'ui/screens/services/service_detail_screen.dart';
import 'ui/screens/splash/splash_screen.dart';
import 'ui/theme/app_theme.dart';
>>>>>>> origin/master

class EmprendeApp extends StatelessWidget {
  const EmprendeApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ReviewsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Conecta Local',
        theme: AppTheme.lightTheme,
        initialRoute: WelcomeScreen.routeName,
        routes: {
          WelcomeScreen.routeName: (_) => const WelcomeScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          HomeScreen.routeName: (_) => const HomeScreen(),
          SearchScreen.routeName: (_) => const SearchScreen(),
          MapScreen.routeName: (_) => const MapScreen(),
          ChatListScreen.routeName: (_) => const ChatListScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          EditProfileScreen.routeName: (_) => const EditProfileScreen(),
          MyServicesScreen.routeName: (_) => const MyServicesScreen(),
          CreateServiceScreen.routeName: (_) => const CreateServiceScreen(),
          ReviewsScreen.routeName: (_) => const ReviewsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == ServiceDetailScreen.routeName) {
            final service = settings.arguments as ServiceModel;
            return MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(service: service),
            );
          }

          if (settings.name == ChatDetailScreen.routeName) {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                chatId: args['chatId'] as String,
                otherUserId: args['otherUserId'] as String,
                otherUserName: args['otherUserName'] as String,
                otherUserPhoto: args['otherUserPhoto'] as String?,
              ),
            );
          }

          if (settings.name == ReviewsScreen.routeName) {
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => ReviewsScreen(
                targetUserId: args?['targetUserId'] as String?,
                serviceId: args?['serviceId'] as String?,
                canReview: args?['canReview'] as bool? ?? false,
              ),
            );
          }

          return null;
        },
      ),
=======
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Conecta Local',
      theme: AppTheme.lightTheme,
      initialRoute: SplashScreen.routeName, // '/' apunta al splash
      routes: {
        SplashScreen.routeName:       (_) => const SplashScreen(),
        WelcomeScreen.routeName:      (_) => const WelcomeScreen(),
        LoginScreen.routeName:        (_) => const LoginScreen(),
        RegisterScreen.routeName:     (_) => const RegisterScreen(),
        HomeScreen.routeName:         (_) => const HomeScreen(),
        SearchScreen.routeName:       (_) => const SearchScreen(),
        MapScreen.routeName:          (_) => const MapScreen(),
        ChatListScreen.routeName:     (_) => const ChatListScreen(),
        ProfileScreen.routeName:      (_) => const ProfileScreen(),
        EditProfileScreen.routeName:  (_) => const EditProfileScreen(),
        MyServicesScreen.routeName:   (_) => const MyServicesScreen(),
        CreateServiceScreen.routeName:(_) => const CreateServiceScreen(),
        ReviewsScreen.routeName:      (_) => const ReviewsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == ServiceDetailScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const ServiceDetailScreen(),
          );
        }
        if (settings.name == ChatDetailScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const ChatDetailScreen(),
          );
        }
        return null;
      },
>>>>>>> origin/master
    );
  }
}