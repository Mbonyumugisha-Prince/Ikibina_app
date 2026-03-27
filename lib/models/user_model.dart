import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final bool emailVerified;
  final DateTime createdAt;
  final String? activeGroupId;
  final String? activeGroupRole;
  final Map<String, dynamic>? notificationSettings;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.emailVerified = false,
    required this.createdAt,
    this.activeGroupId,
    this.activeGroupRole,
    this.notificationSettings,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      photoUrl: map['photoUrl'],
      emailVerified: map['emailVerified'] as bool? ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      activeGroupId: map['activeGroupId'] as String?,
      activeGroupRole: map['activeGroupRole'] as String?,
      notificationSettings:
          (map['notificationSettings'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'activeGroupId': activeGroupId,
      'activeGroupRole': activeGroupRole,
      'notificationSettings': notificationSettings,
    };
  }
}
