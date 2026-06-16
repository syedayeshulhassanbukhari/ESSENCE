import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfile.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return UserProfile(
      uid: snapshot.id,
      email: data['email'] is String ? data['email'] as String : '',
      displayName: data['displayName'] is String ? data['displayName'] as String : '',
      photoUrl: data['photoUrl'] is String ? data['photoUrl'] as String : '',
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
