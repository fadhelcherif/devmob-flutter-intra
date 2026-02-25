import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';

class GroupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _groupsCollection = FirebaseFirestore.instance
      .collection('groups');

  // Create new group
  Future<String> createGroup({
    required String name,
    required String description,
    required String createdBy,
    required String creatorName,
    required String creatorImage,
    required bool isPublic,
  }) async {
    try {
      DocumentReference docRef = _groupsCollection.doc();

      GroupModel group = GroupModel(
        id: docRef.id,
        name: name,
        description: description,
        createdBy: createdBy,
        creatorName: creatorName,
        creatorImage: creatorImage,
        isPublic: isPublic,
        members: [createdBy], // Creator is first member
        createdAt: DateTime.now(),
      );

      await docRef.set(group.toMap());
      return docRef.id;
    } catch (e) {
      print('Create group error: $e');
      throw e;
    }
  }

  // Get all groups
  Stream<List<GroupModel>> getAllGroups() {
    return _groupsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return GroupModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  // Request to join private group
  Future<void> requestToJoinGroup(String groupId, String userId) async {
    try {
      await _groupsCollection.doc(groupId).update({
        'pendingMembers': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Request to join error: $e');
      throw e;
    }
  }

  // Approve member (creator only)
  Future<void> approveMember(String groupId, String userId) async {
    try {
      await _groupsCollection.doc(groupId).update({
        'pendingMembers': FieldValue.arrayRemove([userId]),
        'members': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Approve member error: $e');
      throw e;
    }
  }

  // Reject member request (creator only)
  Future<void> rejectMember(String groupId, String userId) async {
    try {
      await _groupsCollection.doc(groupId).update({
        'pendingMembers': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Reject member error: $e');
      throw e;
    }
  }

  // Get groups where user is member
  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _groupsCollection
        .where('members', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return GroupModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  // Join group
  Future<void> joinGroup(String groupId, String userId) async {
    try {
      await _groupsCollection.doc(groupId).update({
        'members': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Join group error: $e');
      throw e;
    }
  }

  // Leave group
  Future<void> leaveGroup(String groupId, String userId) async {
    try {
      await _groupsCollection.doc(groupId).update({
        'members': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      print('Leave group error: $e');
      throw e;
    }
  }

  // Get single group
  Future<GroupModel?> getGroup(String groupId) async {
    try {
      DocumentSnapshot doc = await _groupsCollection.doc(groupId).get();
      if (doc.exists) {
        return GroupModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Get group error: $e');
    }
    return null;
  }
}
