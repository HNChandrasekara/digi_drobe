import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/channel.dart';
import '../models/chat_message.dart';

class CommunityService {
  static final _db = FirebaseFirestore.instance;
  static const _channelsCol = 'channels';

  // ── Stream channels ──────────────────────────────────────────────────────────
  Stream<List<Channel>> getChannelsStream() {
    return _db.collection(_channelsCol).snapshots().map(
          (snap) => snap.docs.map(Channel.fromFirestore).toList(),
        );
  }

  // ── Stream messages for a channel ───────────────────────────────────────────
  Stream<List<ChatMessage>> getMessagesStream(String channelId) {
    return _db
        .collection(_channelsCol)
        .doc(channelId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .limitToLast(100)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromFirestore).toList());
  }

  // ── Send a message ───────────────────────────────────────────────────────────
  Future<void> sendMessage(String channelId, ChatMessage message) async {
    await _db
        .collection(_channelsCol)
        .doc(channelId)
        .collection('messages')
        .add(message.toFirestore());
  }

  // ── Seed default channels (called once on first run) ────────────────────────
  Future<void> seedChannelsIfEmpty() async {
    final snap = await _db.collection(_channelsCol).limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final channels = [
      {
        'name': 'Daily Outfit Inspirations (OOTD)',
        'description': 'Share your daily outfits and get inspired',
        'memberCount': 1240,
      },
      {
        'name': 'Thrift & Vintage Finds',
        'description': 'Discover and share amazing thrift store finds',
        'memberCount': 892,
      },
      {
        'name': 'Wardrobe Essentials',
        'description': 'Tips for building the perfect capsule wardrobe',
        'memberCount': 2103,
      },
    ];

    final batch = _db.batch();
    for (final channel in channels) {
      final ref = _db.collection(_channelsCol).doc();
      batch.set(ref, channel);
    }
    await batch.commit();
  }
}
