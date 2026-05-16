import 'package:cloud_firestore/cloud_firestore.dart';

class Channel {
  final String id;
  final String name;
  final String description;
  int memberCount;

  Channel({
    required this.id,
    required this.name,
    required this.description,
    this.memberCount = 0,
  });

  factory Channel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Channel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      memberCount: (data['memberCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
    'memberCount': memberCount,
  };
}
