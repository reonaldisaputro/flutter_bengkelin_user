class MerkMobilModel {
  final int id;
  final String namaMerk;
  final String? logo;
  final String? deskripsi;
  final String createdAt;
  final String updatedAt;
  final String? logoUrl;

  MerkMobilModel({
    required this.id,
    required this.namaMerk,
    this.logo,
    this.deskripsi,
    required this.createdAt,
    required this.updatedAt,
    this.logoUrl,
  });

  factory MerkMobilModel.fromJson(Map<String, dynamic> json) {
    return MerkMobilModel(
      id: json['id'] ?? 0,
      namaMerk: json['nama_merk'] ?? '',
      logo: json['logo'],
      deskripsi: json['deskripsi'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      logoUrl: json['logo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_merk': namaMerk,
      'logo': logo,
      'deskripsi': deskripsi,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'logo_url': logoUrl,
    };
  }
}
