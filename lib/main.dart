import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO(handoff): Firebase init shu yerda — firebase_options.dart yaratilgach.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // TODO(handoff): Yandex MapKit init shu yerda — AppConfig.yandexMapsApiKey bilan.
  // await AndroidYandexMap.useAndroidViewSurface(false);

  runApp(const ProviderScope(child: TuronSuvApp()));
}
