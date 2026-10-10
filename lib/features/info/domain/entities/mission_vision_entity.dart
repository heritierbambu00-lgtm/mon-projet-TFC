class MissionVisionEntity {
  final String id;
  final String mission;
  final String vision;
  final String valeurs;

  MissionVisionEntity({
    required this.id,
    required this.mission,
    required this.vision,
    required this.valeurs,
  });

  factory MissionVisionEntity.fromMap(Map<String, dynamic> map, String id) {
    return MissionVisionEntity(
      id: id,
      mission: map['mission'] ?? '',
      vision: map['vision'] ?? '',
      valeurs: map['valeurs'] ?? '',
    );
  }
}
