import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:cotab/utils/invite_code.dart';

void main() {
  test('Invite codes have 6 allowed characters', () {
    final random = Random(42);

    // Try many codes, because they are random.
    for (int i = 0; i < 1000; i++) {
      final code = generateInviteCode(random);

      expect(code.length, 6);
      for (int j = 0; j < code.length; j++) {
        expect(inviteCodeAlphabet.contains(code[j]), isTrue);
      }
    }
  });

  test('Confusing characters are not in the alphabet', () {
    expect(inviteCodeAlphabet.contains('0'), isFalse);
    expect(inviteCodeAlphabet.contains('O'), isFalse);
    expect(inviteCodeAlphabet.contains('1'), isFalse);
    expect(inviteCodeAlphabet.contains('I'), isFalse);
  });

  test('normalizeInviteCode removes spaces and makes it uppercase', () {
    expect(normalizeInviteCode('  k7m2qx '), 'K7M2QX');
  });
}
