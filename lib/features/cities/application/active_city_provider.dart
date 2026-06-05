import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/application/current_user_provider.dart';
import '../data/city_repository.dart';

const _kActiveCityIdKey = 'active_city_id';

class ActiveCityController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final user = await ref.watch(currentUserProvider.future);
    if (user == null) return null;

    if (!user.role.isSuperAdmin) {
      return user.cityIds.isNotEmpty ? user.cityIds.first : null;
    }

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kActiveCityIdKey);

    final cities = await ref.read(cityRepositoryProvider).getAll();
    if (cities.isEmpty) return null;

    if (saved != null && cities.any((c) => c.id == saved)) return saved;

    final fallback = cities.first.id;
    await prefs.setString(_kActiveCityIdKey, fallback);
    return fallback;
  }

  Future<void> set(String cityId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kActiveCityIdKey, cityId);
    state = AsyncValue.data(cityId);
  }
}

final activeCityProvider =
    AsyncNotifierProvider<ActiveCityController, String?>(ActiveCityController.new);
