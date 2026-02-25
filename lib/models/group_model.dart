import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final String creatorName;
  final String creatorImage;
  final bool isPublic;
  final List<String> members;
  final DateTime createdAt;
  final List<String> pendingMembers; // For private groups

  // Add to toMap
  // Add to fromMap

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.creatorName,
    required this.creatorImage,
    required this.isPublic,
    this.members = const [],
    required this.createdAt,
    // Add to constructor
    this.pendingMembers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'creatorName': creatorName,
      'creatorImage': creatorImage,
      'isPublic': isPublic,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),

      'pendingMembers': pendingMembers,
    };
  }

  factory GroupModel.fromMap(String id, Map<String, dynamic> map) {
    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      creatorName: map['creatorName'] ?? '',
      creatorImage: map['creatorImage'] ?? '',
      isPublic: map['isPublic'] ?? true,
      members: List<String>.from(map['members'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      pendingMembers: List<String>.from(map['pendingMembers'] ?? []),
    );
  }
}
