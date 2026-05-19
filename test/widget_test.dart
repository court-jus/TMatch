import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:tmatch/features/game/domain/person_ai.dart';

void main() {
  test('PersonAI can be instantiated', () {
    final ai = PersonAI(Random(0));
    expect(ai, isA<PersonAI>());
  });
}
