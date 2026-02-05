import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/model/bengkel_model.dart';
import 'package:flutter_bengkelin_user/viewmodel/bengkel_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/booking_form_page.dart';
import 'package:flutter_bengkelin_user/views/product_detail_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final response = await BengkelViewmodel().detailBengkel(
      bengkelId: widget.bengkelId,
    );
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

    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        appBar: AppBar(title: Text(bengkel.name), centerTitle: true),
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
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Nama dan alamat
              Text(
                bengkel.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Alamat dengan tombol Google Maps
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                "Alamat",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${bengkel.alamat}, ${bengkel.kelurahan?.name ?? ''}, ${bengkel.kecamatan?.name ?? ''}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        if (bengkel.distance > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.near_me,
                                  size: 14,
                                  color: Colors.blue[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${bengkel.distance.toStringAsFixed(1)} km dari lokasi Anda",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _openGoogleMaps(bengkel.latitude, bengkel.longitude),
                    icon: const Icon(
                      Icons.map_outlined,
                      size: 18,
                      color: Color(0xFF4A6B6B),
                    ),
                    label: const Text(
                      'Buka Maps',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A6B6B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      side: const BorderSide(
                        color: Color(0xFF4A6B6B),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size.zero,
                      backgroundColor: const Color(
                        0xFF4A6B6B,
                      ).withOpacity(0.05),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Deskripsi
              Text(bengkel.description, style: const TextStyle(fontSize: 16)),
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

              // Merk Mobil yang Dilayani
              Text(
                "Merk Mobil yang Dilayani",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              bengkel.merkMobils.isEmpty
                  ? const Text("Belum ada merk mobil yang terdaftar.")
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: bengkel.merkMobils.map((merk) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_car,
                                size: 18,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                merk.namaMerk,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

              const SizedBox(height: 24),

              Text(
                "Jadwal Buka",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              bengkel.jadwals.isEmpty
                  ? const Text("Belum ada jadwal tersedia.")
                  : Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildJadwalRow(
                              "Senin",
                              bengkel.jadwals.first.seninBuka,
                              bengkel.jadwals.first.seninTutup,
                            ),
                            _buildJadwalRow(
                              "Selasa",
                              bengkel.jadwals.first.selasaBuka,
                              bengkel.jadwals.first.selasaTutup,
                            ),
                            _buildJadwalRow(
                              "Rabu",
                              bengkel.jadwals.first.rabuBuka,
                              bengkel.jadwals.first.rabuTutup,
                            ),
                            _buildJadwalRow(
                              "Kamis",
                              bengkel.jadwals.first.kamisBuka,
                              bengkel.jadwals.first.kamisTutup,
                            ),
                            _buildJadwalRow(
                              "Jumat",
                              bengkel.jadwals.first.jumatBuka,
                              bengkel.jadwals.first.jumatTutup,
                            ),
                            _buildJadwalRow(
                              "Sabtu",
                              bengkel.jadwals.first.sabtuBuka,
                              bengkel.jadwals.first.sabtuTutup,
                            ),
                            _buildJadwalRow(
                              "Minggu",
                              bengkel.jadwals.first.mingguBuka,
                              bengkel.jadwals.first.mingguTutup,
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 24),
              Text(
                "Produk Tersedia",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (bengkel.products.isEmpty) const Text("Belum ada produk."),
              ...bengkel.products.map((product) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailPage(productId: product.id),
                        ),
                      );
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(productId: product.id),
                          ),
                        );
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
              ),
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
              icon: const Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: Colors.white,
              ),
              label: const Text(
                "Booking Sekarang",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BookingFormPage(bengkelId: bengkel.id),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    // Prioritize universal Google Maps URLs that work across platforms
    final List<String> urlSchemes = [
      // Universal Google Maps URL (works on both platforms, opens in app if installed, browser if not)
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      // Alternative universal URL
      'https://maps.google.com/?q=$latitude,$longitude',
      // iOS specific scheme (only try on iOS)
      if (Theme.of(context).platform == TargetPlatform.iOS)
        'maps://?q=$latitude,$longitude',
      // Android specific intent (only try on Android)
      if (Theme.of(context).platform == TargetPlatform.android)
        'geo:$latitude,$longitude?q=$latitude,$longitude',
    ];

    bool launched = false;

    for (String url in urlSchemes) {
      try {
        final Uri uri = Uri.parse(url);

        // For https URLs, always try to launch without checking canLaunchUrl
        // as they should always be available
        if (url.startsWith('https://')) {
          launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (launched) break;
        } else {
          // For app-specific schemes, check availability first
          if (await canLaunchUrl(uri)) {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            if (launched) break;
          }
        }
      } catch (e) {
        // Continue to next URL scheme
        debugPrint('Failed to launch $url: $e');
        continue;
      }
    }

    if (!launched) {
      // Show error message if no scheme worked
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Membuka Google Maps di browser...'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );

        // As last resort, open in browser
        final fallbackUrl =
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
        await launchUrl(
          Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    }
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
