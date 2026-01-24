import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import '../viewmodel/chat_viewmodel.dart';
import 'booking_detail_page.dart';
import '../widget/custom_toast.dart';

class ChatAssistantPage extends StatefulWidget {
  const ChatAssistantPage({super.key});

  @override
  State<ChatAssistantPage> createState() => _ChatAssistantPageState();
}

class _ChatAssistantPageState extends State<ChatAssistantPage> {
  final _vm = ChatViewmodel();
  final _input = TextEditingController();
  final _scroll = ScrollController();

  String? _contextId;
  bool _sending = false;

  /// Pesan ditampilkan apa adanya dari API:
  /// Supports: text, link, card, carousel, product_card, booking_card, time_picker, user
  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _quickReplies = [];

  /// Flow info untuk multi-turn conversations (booking flow, etc)
  Map<String, dynamic>? _currentFlow;

  @override
  void initState() {
    super.initState();
    // Mulai dari menu
    Future.microtask(() => _send(payload: 'menu'));
  }

  /// Get current GPS location (like in home_page.dart)
  Future<Position?> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) showToast(context: context, msg: "Layanan lokasi dimatikan.");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) showToast(context: context, msg: "Izin lokasi ditolak.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        showToast(
          context: context,
          msg: "Izin lokasi ditolak permanen, mohon aktifkan di pengaturan.",
        );
      }
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _send({String? message, String? payload}) async {
    setState(() {
      _sending = true;
    });

    // Tampilkan echo user message (biar terasa responsif)
    if (message != null && message.trim().isNotEmpty) {
      _messages.add({'type': 'user', 'text': message.trim()});
      _jumpToBottom();
    }

    // Special handling for "Bengkel Terdekat" - get GPS location
    double? latitude;
    double? longitude;
    const double radius = 10; // Default radius 10km

    if (payload == 'nearby_prompt') {
      final position = await _getCurrentPosition();
      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
      } else {
        // Location permission denied or service disabled
        setState(() {
          _sending = false;
        });
        return;
      }
    }

    final resp = await _vm.send(
      message: message,
      payload: payload,
      contextId: _contextId,
      latitude: latitude,
      longitude: longitude,
      radius: latitude != null ? radius : null,
    );

    if (!mounted) return;

    if (resp.code == 200) {
      final Map<String, dynamic> d = Map<String, dynamic>.from(resp.data ?? {});
      final List apiMsgs = (d['messages'] ?? []) as List;
      final List apiQR = (d['quick_replies'] ?? []) as List;
      final flow = d['flow'];

      // Debug logging
      debugPrint("=== CHAT RESPONSE DEBUG ===");
      debugPrint("Messages count: ${apiMsgs.length}");
      for (var msg in apiMsgs) {
        debugPrint("Message type: ${msg['type']}");
      }
      debugPrint("=========================");

      setState(() {
        _contextId = (d['context_id'] ?? _contextId)?.toString();
        _messages.addAll(apiMsgs.map((e) => Map<String, dynamic>.from(e)));
        _quickReplies = apiQR.map((e) => Map<String, dynamic>.from(e)).toList();
        _currentFlow = flow != null ? Map<String, dynamic>.from(flow) : null;
        _sending = false;
      });
      _jumpToBottom();
    } else {
      setState(() {
        _sending = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.message ?? 'Gagal mengirim pesan')),
        );
      }
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asisten Bengkelin'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Flow indicator
          if (_currentFlow != null && _currentFlow!['active'] == true)
            _FlowIndicator(
              flowName: _currentFlow!['name']?.toString() ?? '',
              step: _currentFlow!['step']?.toString() ?? '',
              canCancel: _currentFlow!['can_cancel'] == true,
              onCancel: _sending ? null : () => _send(payload: 'cancel'),
            ),
          // daftar pesan
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (_, i) {
                if (_sending && i == _messages.length) {
                  return const _TypingBubble();
                }
                final m = _messages[i];
                final type = (m['type'] ?? 'text').toString().toLowerCase().trim();

                // Debug: Log type untuk setiap message
                debugPrint("Rendering message $i with type: '$type'");

                switch (type) {
                  case 'user':
                    return _UserBubble(text: m['text']?.toString() ?? '');
                  case 'text':
                    return _BotTextBubble(text: m['text']?.toString() ?? '');
                  case 'link':
                    return _BotLinkBubble(
                      title: m['title']?.toString() ?? 'Link',
                      url: m['url']?.toString() ?? '',
                    );
                  case 'card':
                    return _BotCardBubble(
                      title: m['title']?.toString() ?? 'Info',
                      subtitle: m['subtitle']?.toString(),
                      image: m['image']?.toString(),
                      actions: (m['actions'] as List? ?? const [])
                          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                          .toList(),
                      onPayload: _sending ? null : (p) => _send(payload: p),
                    );
                  case 'carousel':
                    return _BotCarouselBubble(
                      items: (m['items'] as List? ?? const [])
                          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                          .toList(),
                      onPayload: _sending ? null : (p) => _send(payload: p),
                    );
                  case 'product_card':
                    return _BotProductCardBubble(
                      id: m['id'],
                      name: m['name']?.toString() ?? '',
                      priceFormatted: m['price_formatted']?.toString() ?? '',
                      bengkel: m['bengkel']?.toString() ?? '',
                      stock: m['stock'] ?? 0,
                      image: m['image']?.toString(),
                      actions: (m['actions'] as List? ?? const [])
                          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                          .toList(),
                      onPayload: _sending ? null : (p) => _send(payload: p),
                    );
                  case 'booking_card':
                    return _BotBookingCardBubble(
                      id: m['id'],
                      bengkel: m['bengkel'] != null
                          ? Map<String, dynamic>.from(m['bengkel'])
                          : null,
                      tanggal: m['tanggal']?.toString() ?? '',
                      waktu: m['waktu']?.toString() ?? '',
                      vehicle: m['vehicle'] != null
                          ? Map<String, dynamic>.from(m['vehicle'])
                          : null,
                      status: m['status']?.toString() ?? '',
                      actions: (m['actions'] as List? ?? const [])
                          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                          .toList(),
                      onPayload: _sending ? null : (p) => _send(payload: p),
                      onNavigateToDetail: (bookingId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingDetailPage(bookingId: bookingId),
                          ),
                        );
                      },
                    );
                  case 'time_picker':
                    return _BotTimePickerBubble(
                      date: m['date']?.toString() ?? '',
                      availableSlots: (m['available_slots'] as List? ?? const [])
                          .map((e) => e.toString())
                          .toList(),
                      bookedSlots: (m['booked_slots'] as List? ?? const [])
                          .map((e) => e.toString())
                          .toList(),
                      onSelectTime: _sending ? null : (time) => _send(payload: 'select_time_$time'),
                    );
                  default:
                    debugPrint("⚠️ Unknown message type: '$type' - displaying as raw text");
                    debugPrint("Message content: $m");
                    return _BotTextBubble(text: 'Tipe pesan tidak dikenal: $type');
                }
              },
            ),
          ),

          // quick replies
          if (_quickReplies.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickReplies.map((qr) {
                  final title = qr['title']?.toString() ?? '';
                  final payload = qr['payload']?.toString() ?? '';

                  // BACA TIPE BARU DARI API. Default-nya 'payload'.
                  final type = qr['type']?.toString() ?? 'payload';

                  return ActionChip(
                    label: Text(title),
                    onPressed: _sending
                        ? null
                        : () {
                      // LOGIKA BARU: Kirim berdasarkan tipe
                      if (type == 'message') {
                        _send(message: payload);
                      } else {
                        _send(payload: payload);
                      }
                    },
                  );
                }).toList(),
              ),
            ),

          // input
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Tulis pesan… (mis. "status TRANS-435")',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _onSendPressed(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _sending ? null : _onSendPressed,
                    icon: _sending
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send_rounded),
                    label: Text(_sending ? '...' : 'Kirim'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSendPressed() {
    final txt = _input.text.trim();
    if (txt.isEmpty) return;
    _input.clear();
    _send(message: txt);
  }
}

/// -----------------------------
/// Bubbles & Widgets
/// -----------------------------

/// Flow indicator untuk multi-turn conversations
class _FlowIndicator extends StatelessWidget {
  const _FlowIndicator({
    required this.flowName,
    required this.step,
    required this.canCancel,
    this.onCancel,
  });

  final String flowName;
  final String step;
  final bool canCancel;
  final VoidCallback? onCancel;

  String _getFlowLabel() {
    switch (flowName) {
      case 'booking':
        return 'Booking Bengkel';
      case 'rating':
        return 'Beri Rating';
      default:
        return flowName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        border: Border(bottom: BorderSide(color: cs.outline.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Icon(Icons.sync, size: 16, color: cs.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_getFlowLabel()} • $step',
              style: TextStyle(
                fontSize: 13,
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (canCancel)
            TextButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Batal'),
              style: TextButton.styleFrom(
                foregroundColor: cs.error,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6))],
        ),
        child: Text(text, style: TextStyle(color: cs.onPrimary)),
      ),
    );
  }
}

class _BotTextBubble extends StatelessWidget {
  const _BotTextBubble({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border.all(color: cs.outlineVariant),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 4))],
        ),
        child: Text(text),
      ),
    );
  }
}

class _BotLinkBubble extends StatelessWidget {
  const _BotLinkBubble({required this.title, required this.url});
  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: const BoxConstraints(maxWidth: 360),
        child: ListTile(
          tileColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: cs.outlineVariant),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: const Icon(Icons.link_rounded),
          title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(url, style: TextStyle(color: cs.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ),
    );
  }
}

/// Card bubble dengan support untuk image dan payload actions
class _BotCardBubble extends StatelessWidget {
  const _BotCardBubble({
    required this.title,
    this.subtitle,
    this.image,
    required this.actions,
    this.onPayload,
  });

  final String title;
  final String? subtitle;
  final String? image;
  final List<Map<String, dynamic>> actions;
  final void Function(String payload)? onPayload;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: 320,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null && image!.isNotEmpty)
              Image.network(
                image!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: cs.surfaceContainerHighest,
                  child: Icon(Icons.image_not_supported, color: cs.outline),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if ((subtitle ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: TextStyle(color: Colors.grey[700])),
                  ],
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: actions.map((a) => _buildActionButton(a, cs)).toList(),
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> action, ColorScheme cs) {
    final label = action['label']?.toString() ?? 'Buka';
    final url = action['url']?.toString();
    final payload = action['payload']?.toString();

    // Jika ada payload, gunakan onPayload callback
    if (payload != null && payload.isNotEmpty) {
      return FilledButton.tonal(
        onPressed: onPayload != null ? () => onPayload!(payload) : null,
        child: Text(label),
      );
    }

    // Jika ada URL, buka di browser
    if (url != null && url.isNotEmpty) {
      return OutlinedButton.icon(
        icon: const Icon(Icons.open_in_new_rounded, size: 16),
        label: Text(label),
        onPressed: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      );
    }

    return OutlinedButton(onPressed: null, child: Text(label));
  }
}

/// Carousel - horizontal scrollable cards
class _BotCarouselBubble extends StatelessWidget {
  const _BotCarouselBubble({
    required this.items,
    this.onPayload,
  });

  final List<Map<String, dynamic>> items;
  final void Function(String payload)? onPayload;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 260,
            child: _BotCardBubble(
              title: item['title']?.toString() ?? '',
              subtitle: item['subtitle']?.toString(),
              image: item['image']?.toString(),
              actions: (item['actions'] as List? ?? const [])
                  .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                  .toList(),
              onPayload: onPayload,
            ),
          );
        },
      ),
    );
  }
}

/// Product card dengan harga dan stock
class _BotProductCardBubble extends StatelessWidget {
  const _BotProductCardBubble({
    required this.id,
    required this.name,
    required this.priceFormatted,
    required this.bengkel,
    required this.stock,
    this.image,
    required this.actions,
    this.onPayload,
  });

  final dynamic id;
  final String name;
  final String priceFormatted;
  final String bengkel;
  final int stock;
  final String? image;
  final List<Map<String, dynamic>> actions;
  final void Function(String payload)? onPayload;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: 320,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null && image!.isNotEmpty)
              Image.network(
                image!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 120,
                  color: cs.surfaceContainerHighest,
                  child: Icon(Icons.shopping_bag, size: 40, color: cs.outline),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    priceFormatted,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.store, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          bengkel,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stock > 0 ? 'Stok: $stock' : 'Stok habis',
                    style: TextStyle(
                      fontSize: 12,
                      color: stock > 0 ? Colors.green[700] : cs.error,
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: actions.map((a) {
                        final label = a['label']?.toString() ?? '';
                        final payload = a['payload']?.toString();
                        final url = a['url']?.toString();

                        if (payload != null && payload.isNotEmpty) {
                          return FilledButton.tonal(
                            onPressed: stock > 0 && onPayload != null
                                ? () => onPayload!(payload)
                                : null,
                            child: Text(label),
                          );
                        }
                        if (url != null && url.isNotEmpty) {
                          return OutlinedButton(
                            onPressed: () async {
                              try {
                                final uri = Uri.parse(url);
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                debugPrint('Error launching URL: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tidak dapat membuka link')),
                                  );
                                }
                              }
                            },
                            child: Text(label),
                          );
                        }
                        return const SizedBox.shrink();
                      }).toList(),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Booking card dengan info bengkel, tanggal, kendaraan
class _BotBookingCardBubble extends StatelessWidget {
  const _BotBookingCardBubble({
    required this.id,
    this.bengkel,
    required this.tanggal,
    required this.waktu,
    this.vehicle,
    required this.status,
    required this.actions,
    this.onPayload,
    this.onNavigateToDetail,
  });

  final dynamic id;
  final Map<String, dynamic>? bengkel;
  final String tanggal;
  final String waktu;
  final Map<String, dynamic>? vehicle;
  final String status;
  final List<Map<String, dynamic>> actions;
  final void Function(String payload)? onPayload;
  final void Function(int bookingId)? onNavigateToDetail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bengkelName = bengkel?['name']?.toString() ?? 'Bengkel';
    final bengkelImage = bengkel?['image']?.toString();
    final vehicleBrand = vehicle?['brand']?.toString() ?? '';
    final vehicleModel = vehicle?['model']?.toString() ?? '';
    final vehiclePlat = vehicle?['plat']?.toString() ?? '';

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: 320,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan gambar bengkel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.3),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: bengkelImage != null
                        ? Image.network(
                            bengkelImage,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              color: cs.primaryContainer,
                              child: Icon(Icons.build, color: cs.onPrimaryContainer),
                            ),
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            color: cs.primaryContainer,
                            child: Icon(Icons.build, color: cs.onPrimaryContainer),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bengkelName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(status, style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tanggal & Waktu
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(tanggal, style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: cs.primary),
                      const SizedBox(width: 4),
                      Text(waktu, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  if (vehicle != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.two_wheeler, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$vehicleBrand $vehicleModel • $vehiclePlat',
                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: actions.map((a) {
                        final label = a['label']?.toString() ?? '';
                        final payload = a['payload']?.toString();
                        final url = a['url']?.toString();

                        if (payload != null && payload.isNotEmpty) {
                          final isCancel = payload.contains('cancel');
                          return isCancel
                              ? OutlinedButton(
                                  onPressed: onPayload != null ? () => onPayload!(payload) : null,
                                  style: OutlinedButton.styleFrom(foregroundColor: cs.error),
                                  child: Text(label),
                                )
                              : FilledButton.tonal(
                                  onPressed: onPayload != null ? () => onPayload!(payload) : null,
                                  child: Text(label),
                                );
                        }
                        if (url != null && url.isNotEmpty) {
                          // Check if URL is a booking detail URL
                          final bookingMatch = RegExp(r'/booking/(\d+)').firstMatch(url);
                          if (bookingMatch != null && onNavigateToDetail != null) {
                            final bookingId = int.parse(bookingMatch.group(1)!);
                            return FilledButton.tonal(
                              onPressed: () => onNavigateToDetail!(bookingId),
                              child: Text(label),
                            );
                          }

                          // Otherwise, open in browser
                          return OutlinedButton(
                            onPressed: () async {
                              try {
                                final uri = Uri.parse(url);
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              } catch (e) {
                                debugPrint('Error launching URL: $e');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tidak dapat membuka link')),
                                  );
                                }
                              }
                            },
                            child: Text(label),
                          );
                        }
                        return const SizedBox.shrink();
                      }).toList(),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Time picker untuk memilih slot waktu booking
class _BotTimePickerBubble extends StatelessWidget {
  const _BotTimePickerBubble({
    required this.date,
    required this.availableSlots,
    required this.bookedSlots,
    this.onSelectTime,
  });

  final String date;
  final List<String> availableSlots;
  final List<String> bookedSlots;
  final void Function(String time)? onSelectTime;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final allSlots = [...availableSlots, ...bookedSlots]..sort();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: 320,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 6))],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Pilih Waktu',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (date.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(date, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allSlots.map((slot) {
                final isBooked = bookedSlots.contains(slot);
                return ChoiceChip(
                  label: Text(slot),
                  selected: false,
                  onSelected: isBooked || onSelectTime == null
                      ? null
                      : (_) => onSelectTime!(slot),
                  backgroundColor: isBooked ? Colors.grey[200] : null,
                  labelStyle: TextStyle(
                    color: isBooked ? Colors.grey : null,
                    decoration: isBooked ? TextDecoration.lineThrough : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                Text('Tersedia', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(width: 12),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                Text('Terisi', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(), SizedBox(width: 4),
            _Dot(), SizedBox(width: 4),
            _Dot(),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot();

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: .2, end: 1).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: const CircleAvatar(radius: 3),
    );
  }
}
