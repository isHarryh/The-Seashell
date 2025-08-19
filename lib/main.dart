// Copyright (c) 2025, Harry Huang

import 'package:flutter/material.dart';
import 'router.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'The Seashell',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(0, 91, 148, 1.0),
          dynamicSchemeVariant: DynamicSchemeVariant.rainbow,
        ),
        fontFamily: 'SourceHanSansSC',
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router.config(),
    );
  }
}
