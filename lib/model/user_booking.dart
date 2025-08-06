class UserBookingModel {
  final int id;
  final int userId;
  final int bengkelId;
  final String waktuBooking;
  final String tanggalBooking;
  final String brand;
  final String model;
  final String plat;
  final String tahunPembuatan;
  final int kilometer;
  final String transmisi;
  final String bookingStatus;
  final String? catatanTambahan;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserBengkelModel? bengkel;

  UserBookingModel({
    required this.id,
    required this.userId,
    required this.bengkelId,
    required this.waktuBooking,
    required this.tanggalBooking,
    required this.brand,
    required this.model,
    required this.plat,
    required this.tahunPembuatan,
    required this.kilometer,
    required this.transmisi,
    required this.bookingStatus,
    this.catatanTambahan,
    required this.createdAt,
    required this.updatedAt,
    required this.bengkel
  });

  factory UserBookingModel.fromJson(Map<String, dynamic> json) {
    return UserBookingModel(
      id: json['id'],
      userId: json['user_id'],
      bengkelId: json['bengkel_id'],
      waktuBooking: json['waktu_booking'],
      tanggalBooking: json['tanggal_booking'],
      brand: json['brand'],
      model: json['model'],
      plat: json['plat'],
      tahunPembuatan: json['tahun_pembuatan'],
      kilometer: json['kilometer'],
      transmisi: json['transmisi'],
      bookingStatus: json['booking_status'],
      catatanTambahan: json['catatan_tambahan'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      bengkel: json['bengkel'] != null
          ? UserBengkelModel.fromJson(json['bengkel'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bengkel_id': bengkelId,
      'waktu_booking': waktuBooking,
      'tanggal_booking': tanggalBooking,
      'brand': brand,
      'model': model,
      'plat': plat,
      'tahun_pembuatan': tahunPembuatan,
      'kilometer': kilometer,
      'transmisi': transmisi,
      'booking_status': bookingStatus,
      'catatan_tambahan': catatanTambahan,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'bengkel': bengkel?.toJson(),
    };
  }
}



class UserBengkelModel {
  final int id;
  final int pemilikId;
  final int? specialistId;
  final String name;
  final String image;
  final String description;
  final String alamat;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int kecamatanId;
  final int kelurahanId;

  UserBengkelModel({
    required this.id,
    required this.pemilikId,
    this.specialistId,
    required this.name,
    required this.image,
    required this.description,
    required this.alamat,
    required this.createdAt,
    required this.updatedAt,
    required this.kecamatanId,
    required this.kelurahanId,
  });

  factory UserBengkelModel.fromJson(Map<String, dynamic> json) {
    return UserBengkelModel(
      id: json['id'],
      pemilikId: json['pemilik_id'],
      specialistId: json['specialist_id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      alamat: json['alamat'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      kecamatanId: json['kecamatan_id'],
      kelurahanId: json['kelurahan_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pemilik_id': pemilikId,
      'specialist_id': specialistId,
      'name': name,
      'image': image,
      'description': description,
      'alamat': alamat,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'kecamatan_id': kecamatanId,
      'kelurahan_id': kelurahanId,
    };
  }
}
