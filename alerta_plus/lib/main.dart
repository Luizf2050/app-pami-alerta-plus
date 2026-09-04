import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseAvailable = false;

  try {
    await Firebase.initializeApp();
    firebaseAvailable = true;
  } on FirebaseException catch (exception) {
    debugPrint('Firebase não configurado: ${exception.code}');
  } catch (exception) {
    debugPrint('Não foi possível iniciar o Firebase: $exception');
  }

  await NotificationService.instance.initialize(
    firebaseAvailable: firebaseAvailable,
  );

  runApp(const AlertaPlusApp());
}

class AlertaPlusApp extends StatelessWidget {
  const AlertaPlusApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ALERTA+',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
      },
    );
  }
}
