import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../viewmodel/chat_viewmodel.dart';

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
  /// { type: 'text'|'link'|'card'|'user', text?, title?, subtitle?, url?, actions?[] }
  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _quickReplies = [];

  @override
  void initState() {
    super.initState();
    // Mulai dari menu
    Future.microtask(() => _send(payload: 'menu'));
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

    final resp = await _vm.send(
      message: message,
      payload: payload,
      contextId: _contextId,
    );

    if (!mounted) return;

    if (resp.code == 200) {
      final Map<String, dynamic> d = Map<String, dynamic>.from(resp.data ?? {});
      final List apiMsgs = (d['messages'] ?? []) as List;
      final List apiQR = (d['quick_replies'] ?? []) as List;

      setState(() {
        _contextId = (d['context_id'] ?? _contextId)?.toString();
        _messages.addAll(apiMsgs.map((e) => Map<String, dynamic>.from(e)));
        _quickReplies = apiQR.map((e) => Map<String, dynamic>.from(e)).toList();
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asisten Bengkelin'),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
                final type = (m['type'] ?? 'text').toString();

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
                      actions: (m['actions'] as List? ?? const [])
                          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                          .toList(),
                    );
                  default:
                    return _BotTextBubble(text: m.toString());
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

class _BotCardBubble extends StatelessWidget {
  const _BotCardBubble({
    required this.title,
    this.subtitle,
    required this.actions,
  });

  final String title;
  final String? subtitle;
  final List<Map<String, dynamic>> actions;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: 360,
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
                children: actions.map((a) {
                  final label = a['label']?.toString() ?? 'Buka';
                  final url = a['url']?.toString() ?? '';
                  return OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: Text(label),
                    onPressed: () async {
                      if (url.isEmpty) return;
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  );
                }).toList(),
              )
            ]
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
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
