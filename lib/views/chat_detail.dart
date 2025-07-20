import 'package:flutter/material.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatName;
  final String avatarPath;

  const ChatDetailPage({
    super.key,
    required this.chatName,
    required this.avatarPath,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages =
      []; // Untuk menyimpan pesan dummy atau lokal

  @override
  void initState() {
    super.initState();
    // Tambahkan beberapa pesan dummy untuk simulasi chat
    _messages.add({'text': 'Halo! Ada yang bisa saya bantu?', 'isUser': false});
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true}); // Tambahkan pesan pengguna
      _messageController.clear();
    });
    // Di sini Anda bisa menambahkan logika untuk mengirim pesan ke backend nyata
    // Untuk contoh ini, kita hanya menambahkan pesan ke daftar lokal.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () {
            Navigator.of(context).pop(); // Kembali ke halaman sebelumnya
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(widget.avatarPath),
            ),
            const SizedBox(width: 10),
            Text(
              widget.chatName,
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {
              // Aksi untuk opsi lainnya
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Untuk menampilkan pesan terbaru di bawah
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message =
                    _messages[_messages.length -
                        1 -
                        index]; // Ambil dari paling baru
                return _buildMessageBubble(message['text'], message['isUser']);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(), // Kirim saat enter
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage, // Kirim saat tombol diklik
                  backgroundColor: const Color(0xFF4A6B6B),
                  elevation: 0,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pembantu untuk membuat bubble pesan
  Widget _buildMessageBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF4A6B6B)
              : Colors.grey[300], // Warna berbeda untuk pengirim
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text(
          message,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
