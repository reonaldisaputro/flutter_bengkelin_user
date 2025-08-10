import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/model/bengkel_model.dart';
import 'package:flutter_bengkelin_user/viewmodel/bengkel_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/booking_form_page.dart';
import 'package:flutter_bengkelin_user/views/product_detail_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../config/app_color.dart';

class BengkelDetailPage extends StatefulWidget {
  const BengkelDetailPage({super.key, required this.bengkelId});
  final dynamic bengkelId;

  @override
  State<BengkelDetailPage> createState() => _BengkelDetailPageState();
}

class _BengkelDetailPageState extends State<BengkelDetailPage> {
  BengkelModel? _bengkelModel;

  @override
  void initState() {
    super.initState();
    getDetailBengkel();
  }

  void getDetailBengkel() async {
    final response = await BengkelViewmodel().detailBengkel(bengkelId: widget.bengkelId);
    if (response.code == 200) {
      setState(() {
        _bengkelModel = BengkelModel.fromJson(response.data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bengkel = _bengkelModel;
    if (bengkel == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(bengkel.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bengkel Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "${dotenv.env["IMAGE_BASE_URL"]}/${bengkel.image}",
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 180,
                    color: AppColor.colorGrey,
                    child: Icon(Icons.image_not_supported, color: Colors.white),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Nama dan alamat
            Text(
              bengkel.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "${bengkel.alamat}, ${bengkel.kelurahan?.name ?? ''}, ${bengkel.kecamatan?.name ?? ''}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Deskripsi
            Text(
              bengkel.description,
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 32),

            // Spesialis
            Text("Spesialis", style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: bengkel.specialists
                  .map((s) => Chip(label: Text(s.name)))
                  .toList(),
            ),

            const SizedBox(height: 24),

            Text("Jadwal Buka", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            bengkel.jadwals.isEmpty
                ? const Text("Belum ada jadwal tersedia.")
                : Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    _buildJadwalRow("Senin", bengkel.jadwals.first.seninBuka, bengkel.jadwals.first.seninTutup),
                    _buildJadwalRow("Selasa", bengkel.jadwals.first.selasaBuka, bengkel.jadwals.first.selasaTutup),
                    _buildJadwalRow("Rabu", bengkel.jadwals.first.rabuBuka, bengkel.jadwals.first.rabuTutup),
                    _buildJadwalRow("Kamis", bengkel.jadwals.first.kamisBuka, bengkel.jadwals.first.kamisTutup),
                    _buildJadwalRow("Jumat", bengkel.jadwals.first.jumatBuka, bengkel.jadwals.first.jumatTutup),
                    _buildJadwalRow("Sabtu", bengkel.jadwals.first.sabtuBuka, bengkel.jadwals.first.sabtuTutup),
                    _buildJadwalRow("Minggu", bengkel.jadwals.first.mingguBuka, bengkel.jadwals.first.mingguTutup),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text("Produk Tersedia", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (bengkel.products.isEmpty)
              const Text("Belum ada produk."),
            ...bengkel.products.map((product) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(productId: product.id),));
                  },
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      "${dotenv.env["IMAGE_BASE_URL"]}/${product.image}",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) => const Icon(Icons.image),
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Rp${product.price}"),
                      Text("Stok: ${product.stock}"),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailPage(product: product),));
                    },
                    child: const Text("Lihat"),
                  ),
                ),
              );
            }).toList(),


          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.calendar_today_rounded, size: 20, color: Colors.white,),
            label: const Text(
              "Booking Sekarang",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => BookingFormPage(bengkelId: 2),));
            },
          ),
        ),
      ),
    );

  }

  Widget _buildJadwalRow(String hari, String buka, String tutup) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hari, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text("$buka - $tutup", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

}
