class AnthemEntity {
  final String id;
  final String titre;
  final String paroles;
  final String? audioUrl;

  AnthemEntity({
    required this.id,
    required this.titre,
    required this.paroles,
    this.audioUrl,
  });

  factory AnthemEntity.fromMap(Map<String, dynamic> map, String id) {
    return AnthemEntity(
      id: id,
      titre: map['titre'] ?? 'Hymne de l\'ISTM',
      paroles: map['paroles'] ?? '',
      audioUrl: map['audio_url'],
    );
  }
}
