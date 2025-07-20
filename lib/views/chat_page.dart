import 'package:flutter/material.dart';
import 'package:flutter_bengkelin_user/views/chat_detail.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key, required String initialMessage});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final TextEditingController _searchController = TextEditingController();

  // Data dummy untuk daftar chat
  final List<Map<String, dynamic>> allChats = [
    {
      'type': 'bot',
      'avatar': 'assets/chatbot.jpg',
      'name': 'Chat Bot',
      'lastMessage': 'lets chat me',
      'time': '09:22',
    },
    {
      'type': 'person',
      'avatar': 'assets/profile1.png',
      'name': 'Bengkel A',
      'lastMessage': 'Ada yang bisa di bantu?',
      'time': '09:22',
    },
    {
      'type': 'person',
      'avatar': 'assets/profile2.png',
      'name': 'Bengkel B',
      'lastMessage': 'Maaf untuk saat ini belu...',
      'time': '09:22',
    },
    {
      'type': 'person',
      'avatar': 'assets/profile3.png',
      'name': 'Budi Santoso',
      'lastMessage': 'Oke, saya tunggu konfirmasinya.',
      'time': 'Kemarin',
    },
    {
      'type': 'person',
      'avatar': 'assets/profile4.jpg',
      'name': 'Servis Cepat',
      'lastMessage': 'Jam berapa bisa saya datang?',
      'time': 'Selasa',
    },
  ];

  List<Map<String, dynamic>> filteredChats = [];

  @override
  void initState() {
    super.initState();
    filteredChats = allChats;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Membersihkan query: menghilangkan karakter non-alfabet dan mengubah ke huruf kecil
    final query = _searchController.text.toLowerCase().replaceAll(
      RegExp(r'[^a-z\s]'),
      '',
    ); // Hanya mempertahankan huruf dan spasi

    setState(() {
      filteredChats = allChats.where((chat) {
        // Membersihkan nama chat juga untuk perbandingan yang lebih baik
        final chatNameCleaned = chat['name']!.toLowerCase().replaceAll(
          RegExp(r'[^a-z\s]'),
          '',
        );
        return chatNameCleaned.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or skills',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Daftar Chat
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: filteredChats.length,
              itemBuilder: (context, index) {
                final chat = filteredChats[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailPage(
                          chatName: chat['name']!,
                          avatarPath: chat['avatar']!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: AssetImage(chat['avatar']!),
                        ),
                        const SizedBox(width: 15),

                        // Nama Pengirim & Pesan Terakhir
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chat['lastMessage']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Waktu
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              chat['time']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
