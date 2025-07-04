import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sufcart_app/features/community/messages/provider/messages_socket_provider.dart';
import 'package:sufcart_app/features/community/repost/socket/repost_socket_provider.dart';
import 'package:sufcart_app/state_management/shared_preference_provider.dart';
import 'package:sufcart_app/utilities/socket/socket_config_provider.dart';
import 'package:sufcart_app/utilities/themes/theme_provider.dart';

import 'features/auth/service/auth_service.dart';
import 'features/community/posts/screen/image_view_screen.dart';
import 'features/community/follows/socket/follows_socket_provider.dart';
import 'features/community/likes/socket/like_socket_provider.dart';
import 'features/community/reactions/socket/reaction_socket_provider.dart';
import 'features/profile/model/user_provider.dart';
import 'features/welcome/screens/splash_screen.dart';
import 'state_management/shared_preference_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferencesService = await SharedPreferencesService.getInstance();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => UserProvider(),
      ),
      ChangeNotifierProvider(create: (_) => SocketConfigProvider()),
      ChangeNotifierProvider(
        create: (context) => ReactionSocketProvider(
          socketConfigProvider: context.read<SocketConfigProvider>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => MessagesSocketProvider(
          socketConfigProvider: context.read<SocketConfigProvider>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => RepostSocketProvider(
          socketConfigProvider: context.read<SocketConfigProvider>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => FollowsSocketProvider(
          socketConfigProvider: context.read<SocketConfigProvider>(),
        ),
      ),
      ChangeNotifierProxyProvider<SocketConfigProvider, LikeSocketProvider>(
        create: (context) => LikeSocketProvider(
          socketConfigProvider: context.read<SocketConfigProvider>(),
        ),
        update: (context, socketConfig, likeSocket) => LikeSocketProvider(
          socketConfigProvider: socketConfig,
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => SharedPreferencesProvider(sharedPreferencesService,Provider.of<ThemeProvider>(context, listen: false),),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: Consumer<AuthService>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SufCart Mobile',
          // theme: ThemeData(
          //   primarySwatch: Colors.blue,
          //   visualDensity: VisualDensity.adaptivePlatformDensity,
          // ),
          // theme: ThemeData.light(),
          theme: themeProvider.getTheme(),
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
