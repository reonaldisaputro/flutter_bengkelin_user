import 'package:flutter_bengkelin_user/model/specialist_model.dart';

import 'kecamatan_model.dart';
import 'kelurahan_model.dart';

class BengkelModel {
  final int id;
  final int pemilikId;
  final int? specialistId;
  final String name;
  final String image;
  final String description;
  final String alamat;
  final String createdAt;
  final String updatedAt;
  final int kecamatanId;
  final int kelurahanId;
  final List<SpecialistModel> specialists;
  final KecamatanModel? kecamatan;
  final KelurahanModel? kelurahan;

  BengkelModel({
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
    required this.specialists,
    this.kecamatan,
    this.kelurahan,
  });

  factory BengkelModel.fromJson(Map<String, dynamic> json) {
    return BengkelModel(
      id: json['id'],
      pemilikId: json['pemilik_id'],
      specialistId: json['specialist_id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      alamat: json['alamat'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      kecamatanId: json['kecamatan_id'],
      kelurahanId: json['kelurahan_id'],
      specialists: (json['specialists'] as List<dynamic>?)
          ?.map((e) => SpecialistModel.fromJson(e))
          .toList() ??
          [],
      kecamatan: json['kecamatan'] != null
          ? KecamatanModel.fromJson(json['kecamatan'])
          : null,
      kelurahan: json['kelurahan'] != null
          ? KelurahanModel.fromJson(json['kelurahan'])
          : null,
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
      'created_at': createdAt,
      'updated_at': updatedAt,
      'kecamatan_id': kecamatanId,
      'kelurahan_id': kelurahanId,
      'specialists': specialists.map((e) => e.toJson()).toList(),
      'kecamatan': kecamatan?.toJson(),
      'kelurahan': kelurahan?.toJson(),
    };
  }
}
