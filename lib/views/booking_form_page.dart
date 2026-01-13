import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/viewmodel/booking_viewmodel.dart';
import 'package:flutter_bengkelin_user/views/home_page.dart';
import 'package:flutter_bengkelin_user/widget/custom_toast.dart';
import 'package:intl/intl.dart';

class BookingFormPage extends StatefulWidget {
  final int bengkelId;
  const BookingFormPage({super.key, required this.bengkelId});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _platController = TextEditingController();
  final _tahunController = TextEditingController();
  final _kmController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedTransmisi;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _platController.dispose();
    _tahunController.dispose();
    _kmController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatDate = _selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
        : '';
    final formatTime = _selectedTime?.format(context) ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Formulir Booking'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Data Kendaraan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                _brandController,
                "Brand Mobil",
                "Contoh: Toyota",
              ),
              _buildTextField(
                _modelController,
                "Model Mobil",
                "Contoh: Avanza",
              ),
              _buildTextField(
                _platController,
                "No. Polisi",
                "Contoh: B 1234 XYZ",
              ),
              _buildTextField(
                _tahunController,
                "Tahun Pembuatan",
                "Contoh: 2015",
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                _kmController,
                "Kilometer",
                "Contoh: 50000",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Transmisi",
                  border: OutlineInputBorder(),
                ),
                value: _selectedTransmisi,
                items: ['Manual', 'Matic'].map((trans) {
                  return DropdownMenuItem(
                    value: trans.toLowerCase(),
                    child: Text(trans),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedTransmisi = val),
                validator: (val) => val == null ? 'Pilih transmisi' : null,
              ),
              const SizedBox(height: 24),
              const Text(
                "Waktu Service",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Tanggal Service",
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: formatDate),
                    validator: (_) =>
                        _selectedDate == null ? 'Pilih tanggal' : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickTime,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Waktu Service",
                      suffixIcon: Icon(Icons.access_time),
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: formatTime),
                    validator: (_) =>
                        _selectedTime == null ? 'Pilih waktu' : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Catatan Tambahan",
                  border: OutlineInputBorder(),
                  hintText: "Tambahkan catatan tambahan di sini",
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  label: const Text(
                    "Selanjutnya",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedDate == null) {
                        showToast(
                          context: context,
                          msg: "Tanggal service wajib diisi",
                        );
                        return;
                      }
                      if (_selectedTime == null) {
                        showToast(
                          context: context,
                          msg: "Waktu service wajib diisi",
                        );
                        return;
                      }
                      if (_selectedTransmisi == null) {
                        showToast(
                          context: context,
                          msg: "Transmisi wajib dipilih",
                        );
                        return;
                      }
                      handleBookingBengkel();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (val) =>
            val == null || val.isEmpty ? 'Field wajib diisi' : null,
      ),
    );
  }

  void handleBookingBengkel() {
    final bookingDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final time = _selectedTime!;
    final bookingTime =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    BookingViewmodel()
        .bookingBengkel(
          bengkelId: widget.bengkelId,
          bookingDate: bookingDate,
          timeBooking: bookingTime,
          brand: _brandController.text.trim(),
          model: _modelController.text.trim(),
          plat: _platController.text.trim(),
          tahunPembuatan: int.tryParse(_tahunController.text.trim()) ?? 0,
          kilometer: int.tryParse(_kmController.text.trim()) ?? 0,
          transmisi: _selectedTransmisi ?? '',
          notes: _noteController.text.trim(),
        )
        .then((value) {
          if (value.code == 200) {
            if (!mounted) return;
            showToast(context: context, msg: value.message);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          } else {
            if (!mounted) return;
            showToast(context: context, msg: value.message);
          }
        });
  }
}
