import 'package:flutter_bengkelin_user/model/specialist_model.dart';

import 'kecamatan_model.dart';
import 'kelurahan_model.dart';
import 'merk_mobil_model.dart';

class BengkelModel {
  final int id;
  final int pemilikId;
  final int? specialistId;
  final String name;
  final String image;
  final String description;
  final String alamat;
  final double latitude;
  final double longitude;
  final double distance;
  final String createdAt;
  final String updatedAt;
  final int kecamatanId;
  final int kelurahanId;
  final List<SpecialistModel> specialists;
  final KecamatanModel? kecamatan;
  final KelurahanModel? kelurahan;
  final List<Product> products;
  final List<JadwalModel> jadwals;
  final List<MerkMobilModel> merkMobils;

  BengkelModel({
    required this.id,
    required this.pemilikId,
    this.specialistId,
    required this.name,
    required this.image,
    required this.description,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.createdAt,
    required this.updatedAt,
    required this.kecamatanId,
    required this.kelurahanId,
    required this.specialists,
    this.kecamatan,
    this.kelurahan,
    required this.products,
    required this.jadwals,
    required this.merkMobils,
  });

  factory BengkelModel.fromJson(Map<String, dynamic> json) {
    // Fungsi kecil untuk parsing yang aman
    int safeIntParse(dynamic value) {
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double safeDoubleParse(dynamic value) {
      return double.tryParse(value?.toString() ?? '') ?? 0.0;
    }

    return BengkelModel(
      // Gunakan fungsi parsing yang aman untuk semua angka
      id: safeIntParse(json['id']),
      pemilikId: safeIntParse(json['pemilik_id']),
      specialistId: json['specialist_id'] != null
          ? safeIntParse(json['specialist_id'])
          : null,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      alamat: json['alamat'] ?? '',

      latitude: safeDoubleParse(json['latitude']),
      longitude: safeDoubleParse(json['longitude']),
      distance: safeDoubleParse(json['distance']),

      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      kecamatanId: safeIntParse(json['kecamatan_id']),
      kelurahanId: safeIntParse(json['kelurahan_id']),

      specialists:
          (json['specialists'] as List<dynamic>?)
              ?.map((e) => SpecialistModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      kecamatan: json['kecamatan'] != null
          ? KecamatanModel.fromJson(json['kecamatan'] as Map<String, dynamic>)
          : null,
      kelurahan: json['kelurahan'] != null
          ? KelurahanModel.fromJson(json['kelurahan'] as Map<String, dynamic>)
          : null,
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      jadwals:
          (json['jadwals'] as List<dynamic>?)
              ?.map((e) => JadwalModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      merkMobils:
          (json['merk_mobils'] as List<dynamic>?)
              ?.map((e) => MerkMobilModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'kecamatan_id': kecamatanId,
      'kelurahan_id': kelurahanId,
      'specialists': specialists.map((e) => e.toJson()).toList(),
      'kecamatan': kecamatan?.toJson(),
      'kelurahan': kelurahan?.toJson(),
      'products': products.map((e) => e.toJson()).toList(),
      'jadwals': jadwals.map((e) => e.toJson()).toList(),
      'merk_mobils': merkMobils.map((e) => e.toJson()).toList(),
    };
  }
}

class Product {
  final int id;
  final String name;
  final String image;
  final String description;
  final int bengkelId;
  final int price;
  final int weight;
  final int stock;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.bengkelId,
    required this.price,
    required this.weight,
    required this.stock,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      bengkelId: json['bengkel_id'] ?? 0,
      price: json['price'] ?? 0,
      weight: json['weight'] ?? 0,
      stock: json['stock'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'bengkel_id': bengkelId,
      'price': price,
      'weight': weight,
      'stock': stock,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class JadwalModel {
  final int id;
  final String seninBuka;
  final String seninTutup;
  final String selasaBuka;
  final String selasaTutup;
  final String rabuBuka;
  final String rabuTutup;
  final String kamisBuka;
  final String kamisTutup;
  final String jumatBuka;
  final String jumatTutup;
  final String sabtuBuka;
  final String sabtuTutup;
  final String mingguBuka;
  final String mingguTutup;
  final int bengkelId;
  final String createdAt;
  final String updatedAt;

  JadwalModel({
    required this.id,
    required this.seninBuka,
    required this.seninTutup,
    required this.selasaBuka,
    required this.selasaTutup,
    required this.rabuBuka,
    required this.rabuTutup,
    required this.kamisBuka,
    required this.kamisTutup,
    required this.jumatBuka,
    required this.jumatTutup,
    required this.sabtuBuka,
    required this.sabtuTutup,
    required this.mingguBuka,
    required this.mingguTutup,
    required this.bengkelId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'] ?? 0,
      seninBuka: json['senin_buka'] ?? '',
      seninTutup: json['senin_tutup'] ?? '',
      selasaBuka: json['selasa_buka'] ?? '',
      selasaTutup: json['selasa_tutup'] ?? '',
      rabuBuka: json['rabu_buka'] ?? '',
      rabuTutup: json['rabu_tutup'] ?? '',
      kamisBuka: json['kamis_buka'] ?? '',
      kamisTutup: json['kamis_tutup'] ?? '',
      jumatBuka: json['jumat_buka'] ?? '',
      jumatTutup: json['jumat_tutup'] ?? '',
      sabtuBuka: json['sabtu_buka'] ?? '',
      sabtuTutup: json['sabtu_tutup'] ?? '',
      mingguBuka: json['minggu_buka'] ?? '',
      mingguTutup: json['minggu_tutup'] ?? '',
      bengkelId: json['bengkel_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senin_buka': seninBuka,
      'senin_tutup': seninTutup,
      'selasa_buka': selasaBuka,
      'selasa_tutup': selasaTutup,
      'rabu_buka': rabuBuka,
      'rabu_tutup': rabuTutup,
      'kamis_buka': kamisBuka,
      'kamis_tutup': kamisTutup,
      'jumat_buka': jumatBuka,
      'jumat_tutup': jumatTutup,
      'sabtu_buka': sabtuBuka,
      'sabtu_tutup': sabtuTutup,
      'minggu_buka': mingguBuka,
      'minggu_tutup': mingguTutup,
      'bengkel_id': bengkelId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
