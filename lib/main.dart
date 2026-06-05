import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase plagini ishlatilmaydi — barcha servislarga HTTP REST orqali murojaat qilamiz.
  // FirebaseAuthRest va FirestoreRest providerlari avtomatik init bo'ladi.
  runApp(const ProviderScope(child: TuronSuvApp()));
}
