import 'dart:math';

const int inviteCodeLength = 6;

// Letters and digits that are easy to read and type. 0/O and 1/I are left
// out because they look alike.
const String inviteCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

// Returns a random code like 'K7M2QX'. Checking that no other group uses
// the code is done by GroupService.
String generateInviteCode(Random random) {
  String code = '';
  for (int i = 0; i < inviteCodeLength; i++) {
    final index = random.nextInt(inviteCodeAlphabet.length);
    code = code + inviteCodeAlphabet[index];
  }
  return code;
}

// Removes spaces and makes the code uppercase, so ' k7m2qx' also works.
String normalizeInviteCode(String code) {
  return code.trim().toUpperCase();
}
