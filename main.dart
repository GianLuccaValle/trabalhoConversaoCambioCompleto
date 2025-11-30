import 'package:flutter/material.dart';
import 'telas/splash_tela.dart';
import 'telas/inicio_tela.dart';
import 'telas/conversao_tela.dart';
import 'telas/historico_tela.dart';

void main() {
  runApp(const ConversorCambioApp());
}

class ConversorCambioApp extends StatelessWidget {
  const ConversorCambioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversor de Câmbio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashTela(),
        '/inicio': (context) => const InicioTela(),
        '/conversao': (context) => const ConversaoTela(),
        '/historico': (context) => const HistoricoTela(),
      },
    );
  }
}