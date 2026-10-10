import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryItem {
  final String id;
  final String imageUrl;
  final String legende;
  final DateTime date;

  GalleryItem({
    required this.id,
    required this.imageUrl,
    required this.legende,
    required this.date,
  });

  factory GalleryItem.fromMap(Map<String, dynamic> map, String id) {
    return GalleryItem(
      id: id,
      imageUrl: map['imageUrl'] ?? map['nom_image'] ?? '',
      legende: map['legende'] ?? map['description'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
