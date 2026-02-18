import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

enum UserRole { employee, admin }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? bio;
  final String? profileImageUrl;
  final UserRole role;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.bio,
    this.profileImageUrl,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'];
    final createdAt = createdAtValue is Timestamp
        ? createdAtValue.toDate()
        : (createdAtValue is String
              ? (DateTime.tryParse(createdAtValue) ??
                    DateTime.fromMillisecondsSinceEpoch(0))
              : DateTime.fromMillisecondsSinceEpoch(0));

    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      bio: map['bio'],
      profileImageUrl: map['profileImageUrl'],
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.employee,
      ),
      createdAt: createdAt,
    );
  }
}
