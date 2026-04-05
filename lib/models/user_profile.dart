import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  String displayName;
  final String email;
  String phone;
  String role; // 'user' or 'admin'
  String? photoUrl;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phone = '',
    this.role = 'user',
    this.photoUrl,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'user',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'phone': phone,
        'role': role,
        'photoUrl': photoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
