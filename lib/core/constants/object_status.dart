import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum ObjectStatus {
  planned('planned'),
  working('working'),
  done('done');

  const ObjectStatus(this.wire);

  final String wire;

  static ObjectStatus fromWire(String? value) {
    return ObjectStatus.values.firstWhere(
      (s) => s.wire == value,
      orElse: () => ObjectStatus.planned,
    );
  }

  String get label {
    switch (this) {
      case ObjectStatus.planned:
        return 'Rejalashtirilgan';
      case ObjectStatus.working:
        return 'Jarayonda';
      case ObjectStatus.done:
        return 'Tugatilgan';
    }
  }

  Color get color {
    switch (this) {
      case ObjectStatus.planned:
        return AppColors.statusPlanned;
      case ObjectStatus.working:
        return AppColors.statusWorking;
      case ObjectStatus.done:
        return AppColors.statusDone;
    }
  }
}
