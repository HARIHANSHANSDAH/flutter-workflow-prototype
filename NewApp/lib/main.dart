import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/auth_screen.dart';
import 'screens/end_user_screen.dart';
import 'screens/receiver_screen.dart';
import 'providers/providers.dart';
import 'models/models.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    return Container(

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Request Workflow',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          scaffoldBackgroundColor: Colors.transparent, // 👈 keep transparent
        ),
        home: Builder(
          builder: (context) {
            if (user == null) return const AuthScreen();
            switch (user.role) {
              case UserRole.EndUser:
                return const EndUserScreen();
              case UserRole.Receiver:
                return const ReceiverScreen();
            }
          },
        ),
      ),
    );

  }
}
