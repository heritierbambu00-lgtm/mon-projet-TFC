import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, audio, deleted }

class ChatFaculteEntity {
  final String id;
  final String idEtu;
  final String nomUtilisateur;
  final String message;
  final MessageType type;
  final String? mediaUrl;
  final String faculte;
  final DateTime dateEnvoi;
  final List<String> deletedBy;

  ChatFaculteEntity({
    required this.id,
    required this.idEtu,
    required this.nomUtilisateur,
    required this.message,
    this.type = MessageType.text,
    this.mediaUrl,
    required this.faculte,
    required this.dateEnvoi,
    this.deletedBy = const [],
  });

  factory ChatFaculteEntity.fromMap(Map<String, dynamic> map, String id) {
    return ChatFaculteEntity(
      id: id,
      idEtu: map['id_etu'] ?? '',
      nomUtilisateur: map['nom_utilisateur'] ?? '',
      message: map['message'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      mediaUrl: map['media_url'],
      faculte: map['faculte'] ?? '',
      dateEnvoi: (map['date_envoi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deletedBy: List<String>.from(map['deleted_by'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_etu': idEtu,
      'nom_utilisateur': nomUtilisateur,
      'message': message,
      'type': type.name,
      'media_url': mediaUrl,
      'faculte': faculte,
      'date_envoi': FieldValue.serverTimestamp(),
      'deleted_by': deletedBy,
    };
  }
}
