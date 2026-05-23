class InterventionPointer {
  final int id;
  final String typeReclamation;
  final String description;
  final String statut;
  final int idOds;
  final int idClient;
  final String adresse;
  final String clientNom;
  final String telephone;
  final double latitude;
  final double longitude;

  InterventionPointer({
    required this.id,
    required this.typeReclamation,
    required this.description,
    required this.statut,
    required this.idOds,
    required this.idClient,
    required this.adresse,
    required this.clientNom,
    required this.telephone,
    required this.latitude,
    required this.longitude,
  });

  factory InterventionPointer.fromJson(Map<String, dynamic> json) {
    return InterventionPointer(
      id: json['id'] ?? 0,
      typeReclamation: json['type_reclamation'] ?? '',
      description: json['description'] ?? '',
      statut: json['statut'] ?? '',
      idOds: json['id_ods'] ?? 0,
      idClient: json['id_client'] ?? 0,
      adresse: json['adresse'] ?? '',
      clientNom: json['client_nom'] ?? '',
      telephone: json['telephone'] ?? '',
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
    );
  }
}