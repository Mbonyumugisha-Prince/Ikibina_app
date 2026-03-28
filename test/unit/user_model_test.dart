import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ikibina/models/user_model.dart';

void main() {
  group('UserModel', () {
    final createdAt = DateTime(2024, 1, 15);

    // ── fromMap ──────────────────────────────
    group('fromMap', () {
      test('parses all fields correctly', () {
        final map = {
          'name': 'Alice',
          'email': 'alice@example.com',
          'phone': '+250788000001',
          'photoUrl': 'https://example.com/photo.jpg',
          'emailVerified': true,
          'twoFactorEnabled': true,
          'createdAt': Timestamp.fromDate(createdAt),
          'activeGroupId': 'g1',
          'activeGroupRole': 'admin',
        };
        final user = UserModel.fromMap('u1', map);
        expect(user.id, 'u1');
        expect(user.name, 'Alice');
        expect(user.email, 'alice@example.com');
        expect(user.phone, '+250788000001');
        expect(user.photoUrl, 'https://example.com/photo.jpg');
        expect(user.emailVerified, isTrue);
        expect(user.twoFactorEnabled, isTrue);
        expect(user.activeGroupId, 'g1');
        expect(user.activeGroupRole, 'admin');
        expect(user.createdAt, createdAt);
      });

      test('defaults emailVerified to false when missing', () {
        final map = {
          'name': 'Bob',
          'email': 'bob@example.com',
          'createdAt': Timestamp.fromDate(createdAt),
        };
        expect(UserModel.fromMap('u2', map).emailVerified, isFalse);
      });

      test('defaults twoFactorEnabled to false when missing', () {
        final map = {
          'name': 'Carol',
          'email': 'carol@example.com',
          'createdAt': Timestamp.fromDate(createdAt),
        };
        expect(UserModel.fromMap('u3', map).twoFactorEnabled, isFalse);
      });

      test('reads twoFactorEnabled as true when set to true in map', () {
        final map = {
          'name': 'Dan',
          'email': 'dan@example.com',
          'createdAt': Timestamp.fromDate(createdAt),
          'twoFactorEnabled': true,
        };
        expect(UserModel.fromMap('u4', map).twoFactorEnabled, isTrue);
      });

      test('handles null phone and photoUrl gracefully', () {
        final map = {
          'name': 'Eve',
          'email': 'eve@example.com',
          'createdAt': Timestamp.fromDate(createdAt),
          'phone': null,
          'photoUrl': null,
        };
        final user = UserModel.fromMap('u5', map);
        expect(user.phone, isNull);
        expect(user.photoUrl, isNull);
      });

      test('handles missing activeGroupId and activeGroupRole', () {
        final map = {
          'name': 'Frank',
          'email': 'frank@example.com',
          'createdAt': Timestamp.fromDate(createdAt),
        };
        final user = UserModel.fromMap('u6', map);
        expect(user.activeGroupId, isNull);
        expect(user.activeGroupRole, isNull);
      });

      test('defaults name and email to empty string when missing', () {
        final map = {'createdAt': Timestamp.fromDate(createdAt)};
        final user = UserModel.fromMap('u7', map);
        expect(user.name, '');
        expect(user.email, '');
      });

      test('parses member role correctly', () {
        final map = {
          'name': 'Grace',
          'email': 'grace@example.com',
          'createdAt': Timestamp.fromDate(createdAt),
          'activeGroupId': 'g2',
          'activeGroupRole': 'member',
        };
        final user = UserModel.fromMap('u8', map);
        expect(user.activeGroupRole, 'member');
      });
    });

    // ── toMap ────────────────────────────────
    group('toMap', () {
      test('includes all required keys', () {
        final user = UserModel(
          id: 'u1',
          name: 'Alice',
          email: 'alice@example.com',
          createdAt: createdAt,
        );
        final map = user.toMap();
        expect(map, contains('name'));
        expect(map, contains('email'));
        expect(map, contains('phone'));
        expect(map, contains('photoUrl'));
        expect(map, contains('emailVerified'));
        expect(map, contains('twoFactorEnabled'));
        expect(map, contains('createdAt'));
        expect(map, contains('activeGroupId'));
        expect(map, contains('activeGroupRole'));
      });

      test('stores twoFactorEnabled as true when enabled', () {
        final user = UserModel(
          id: 'u1',
          name: 'Alice',
          email: 'alice@example.com',
          createdAt: createdAt,
          twoFactorEnabled: true,
        );
        expect(user.toMap()['twoFactorEnabled'], isTrue);
      });

      test('stores twoFactorEnabled as false by default', () {
        final user = UserModel(
          id: 'u1',
          name: 'Bob',
          email: 'bob@example.com',
          createdAt: createdAt,
        );
        expect(user.toMap()['twoFactorEnabled'], isFalse);
      });

      test('stores name and email correctly', () {
        final user = UserModel(
          id: 'u1',
          name: 'Carol',
          email: 'carol@example.com',
          createdAt: createdAt,
        );
        final map = user.toMap();
        expect(map['name'], 'Carol');
        expect(map['email'], 'carol@example.com');
      });
    });

    // ── constructor defaults ─────────────────
    group('constructor defaults', () {
      test('emailVerified defaults to false', () {
        final user = UserModel(
          id: 'u1',
          name: 'Alice',
          email: 'alice@example.com',
          createdAt: createdAt,
        );
        expect(user.emailVerified, isFalse);
      });

      test('twoFactorEnabled defaults to false', () {
        final user = UserModel(
          id: 'u1',
          name: 'Alice',
          email: 'alice@example.com',
          createdAt: createdAt,
        );
        expect(user.twoFactorEnabled, isFalse);
      });
    });

    // ── round-trip ───────────────────────────
    group('round-trip', () {
      test('fromMap → toMap → fromMap preserves twoFactorEnabled', () {
        final original = UserModel(
          id: 'u1',
          name: 'Alice',
          email: 'alice@example.com',
          createdAt: createdAt,
          twoFactorEnabled: true,
          emailVerified: true,
        );
        final copy = UserModel.fromMap('u1', {
          ...original.toMap(),
          'createdAt': Timestamp.fromDate(createdAt),
        });
        expect(copy.twoFactorEnabled, isTrue);
        expect(copy.emailVerified, isTrue);
        expect(copy.name, original.name);
        expect(copy.email, original.email);
      });

      test('fromMap → toMap → fromMap preserves optional fields', () {
        final original = UserModel(
          id: 'u1',
          name: 'Bob',
          email: 'bob@example.com',
          phone: '+250788000002',
          activeGroupId: 'g1',
          activeGroupRole: 'admin',
          createdAt: createdAt,
        );
        final copy = UserModel.fromMap('u1', {
          ...original.toMap(),
          'createdAt': Timestamp.fromDate(createdAt),
        });
        expect(copy.phone, original.phone);
        expect(copy.activeGroupId, original.activeGroupId);
        expect(copy.activeGroupRole, original.activeGroupRole);
      });
    });
  });
}
