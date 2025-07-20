class UserModel {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String phoneNumber;
  final String alamat;
  final String createdAt;
  final String updatedAt;
  final int kecamatanId;
  final int kelurahanId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.phoneNumber,
    required this.alamat,
    required this.createdAt,
    required this.updatedAt,
    required this.kecamatanId,
    required this.kelurahanId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      phoneNumber: json['phone_number'] ?? '',
      alamat: json['alamat'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      kecamatanId: json['kecamatan_id'] ?? 0,
      kelurahanId: json['kelurahan_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'phone_number': phoneNumber,
      'alamat': alamat,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'kecamatan_id': kecamatanId,
      'kelurahan_id': kelurahanId,
    };
  }
}
