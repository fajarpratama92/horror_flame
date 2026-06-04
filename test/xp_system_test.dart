import 'package:flutter_test/flutter_test.dart';
import 'package:horror_flame/features/progression/xp_system.dart';
import 'package:horror_flame/core/utils/constants.dart';

void main() {
  group('XpSystem', () {
    late XpSystem xp;

    setUp(() => xp = XpSystem());

    test('starts at level 1 with 0 XP', () {
      expect(xp.level, equals(1));
      expect(xp.currentXp, equals(0.0));
    });

    test('gainXp returns false when no level up', () {
      expect(xp.gainXp(10.0), isFalse);
      expect(xp.level, equals(1));
    });

    test('gainXp returns true and increments level on threshold', () {
      final threshold = xp.xpToNextLevel;
      expect(xp.gainXp(threshold), isTrue);
      expect(xp.level, equals(2));
    });

    test('XP carries over after level up', () {
      final threshold = xp.xpToNextLevel;
      xp.gainXp(threshold + 20.0);
      expect(xp.currentXp, closeTo(20.0, 0.01));
    });

    test('does not level past max level', () {
      for (var i = 0; i < 100; i++) {
        xp.gainXp(99999.0);
      }
      expect(xp.level, equals(GameConstants.maxLevelPerRun));
    });

    test('isMaxLevel is true at max level', () {
      for (var i = 0; i < 100; i++) xp.gainXp(99999.0);
      expect(xp.isMaxLevel, isTrue);
    });

    test('rollSkillChoices returns correct count', () {
      final choices = xp.rollSkillChoices([]);
      expect(choices.length, equals(GameConstants.skillChoiceCount));
    });

    test('rollSkillChoices excludes already owned skills', () {
      const owned = [SkillId.bloodEdge, SkillId.ironWill, SkillId.blink];
      final choices = xp.rollSkillChoices(owned);
      for (final choice in choices) {
        expect(owned.contains(choice), isFalse);
      }
    });

    test('rollSkillChoices returns unique skills', () {
      final choices = xp.rollSkillChoices([]);
      final unique = choices.toSet();
      expect(unique.length, equals(choices.length));
    });
  });
}
