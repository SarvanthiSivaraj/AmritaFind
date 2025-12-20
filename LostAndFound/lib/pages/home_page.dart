import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'post_item_form_page.dart';
import 'chat_page.dart';
import 'profile_page.dart';
import 'chat_list_page.dart';
import 'chat_bot_page.dart';
import 'login_page.dart' as login;
import '../services/auth_service.dart';

const Color kPrimary = Color(0xFFBF0C4F);
const Color kBackgroundLight = Color(0xFFFAF9F6);

class HomePageFeed extends StatefulWidget {
  const HomePageFeed({super.key});

  @override
  State<HomePageFeed> createState() => _HomePageFeedState();
}

class _HomePageFeedState extends State<HomePageFeed> {
  String _statusFilter = "all";
  String _searchText = "";
  DateTime? _selectedDate;
  String? _selectedLocation;
  String _sortMode = "date";
  bool _sortAscending = false;

  final List<String> _locations = [
    "AB1",
    "AB2",
    "AB3",
    "Auditorium",
    "Lib",
    "Canteen",
    "Parking",
  ];

  /// ------------------------------------------
  /// 🔥 COMBINED LIVE STREAM (lost + found)
  /// ------------------------------------------
  Stream<List<Map<String, dynamic>>> _itemsStream() {
    final lostStream = FirebaseFirestore.instance
        .collection("lost_items")
        .snapshots();
    final foundStream = FirebaseFirestore.instance
        .collection("found_items")
        .snapshots();

    return lostStream.asyncMap((lost) async {
      final found = await foundStream.first;

      final lostList = lost.docs.map((d) {
        return {"id": d.id, ...d.data(), "source": "LOST"};
      }).toList();

      final foundList = found.docs.map((d) {
        return {"id": d.id, ...d.data(), "source": "FOUND"};
      }).toList();

      return [...lostList, ...foundList];
    });
  }

  /// ------------------------------------------
  /// FILTER + SORT
  /// ------------------------------------------
  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> items) {
    List<Map<String, dynamic>> out = List.from(items);

    if (_statusFilter != "all") {
      out = out
          .where((e) => e["source"].toString().toLowerCase() == _statusFilter)
          .toList();
    }

    if (_selectedLocation != null) {
      out = out
          .where(
            (e) =>
                e["location"]?.toString().toUpperCase() ==
                _selectedLocation!.toUpperCase(),
          )
          .toList();
    }

    if (_selectedDate != null) {
      out = out.where((e) {
        final ts = e["timestamp"];
        if (ts == null) return false;
        final dt = (ts as Timestamp).toDate();
        return dt.year == _selectedDate!.year &&
            dt.month == _selectedDate!.month &&
            dt.day == _selectedDate!.day;
      }).toList();
    }

    if (_searchText.isNotEmpty) {
      out = out.where((e) {
        final title = (e["item_name"] ?? e["itemName"] ?? "")
            .toString()
            .toLowerCase();
        return title.contains(_searchText.toLowerCase());
      }).toList();
    }

    out.sort((a, b) {
      if (_sortMode == "date") {
        final da = (a["timestamp"] as Timestamp?)?.toDate() ?? DateTime(2000);
        final db = (b["timestamp"] as Timestamp?)?.toDate() ?? DateTime(2000);
        return _sortAscending ? da.compareTo(db) : db.compareTo(da);
      } else {
        final la = a["location"] ?? "";
        final lb = b["location"] ?? "";
        return _sortAscending ? la.compareTo(lb) : lb.compareTo(la);
      }
    });

    return out;
  }

  /// ------------------------------------------
  /// SELECT DATE
  /// ------------------------------------------
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDate: _selectedDate ?? now,
    );

    if (d != null) setState(() => _selectedDate = d);
  }

  /// CLEAR FILTERS
  void _clearFilters() {
    setState(() {
      _statusFilter = "all";
      _selectedDate = null;
      _selectedLocation = null;
      _sortMode = "date";
      _sortAscending = false;
    });
  }

  /// ------------------------------------------
  /// MAIN UI
  /// ------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundLight,
      appBar: AppBar(
        backgroundColor: kBackgroundLight,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.school, color: kPrimary, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Lost & Found",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: kPrimary),
            onPressed: () async {
              if (!AuthService.isLoggedIn) {
                final loggedIn = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const login.LoginScreen()),
                );
                if (loggedIn != true) return; // User cancelled or failed login
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatListPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble, color: kPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatbotScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: kPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
        ],
      ),

      /// ADD BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        child: const Icon(Icons.add),
        onPressed: () async {
          if (!AuthService.isLoggedIn) {
            final ok = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const login.LoginScreen()),
            );
            if (ok != true) return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostItemFormPage()),
          );
        },
      ),

      body: Column(
        children: [
          // SEARCH BAR
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchText = v),
                    decoration: const InputDecoration(
                      hintText: "Search for 'water bottle', 'ID card'...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // FILTERS
          _buildFilters(),

          const SizedBox(height: 10),

          /// STREAM LIST
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _itemsStream(),
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = _applyFilters(snap.data!);

                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      "No items found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: data.length,
                  itemBuilder: (_, i) => _itemCard(data[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------------------------------
  /// FILTER CHIPS
  /// ------------------------------------------
  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _chip("All", _statusFilter == "all", () {
            setState(() => _statusFilter = "all");
          }),

          _chip("Lost", _statusFilter == "lost", () {
            setState(() => _statusFilter = "lost");
          }),

          _chip("Found", _statusFilter == "found", () {
            setState(() => _statusFilter = "found");
          }),

          _chip("Location", _selectedLocation != null, () async {
            final loc = await showDialog<String?>(
              context: context,
              builder: (_) => SimpleDialog(
                title: const Text("Select Location"),
                children: [
                  SimpleDialogOption(
                    child: const Text("All"),
                    onPressed: () => Navigator.pop(context, null),
                  ),
                  ..._locations.map(
                    (l) => SimpleDialogOption(
                      child: Text(l),
                      onPressed: () => Navigator.pop(context, l),
                    ),
                  ),
                ],
              ),
            );

            setState(() => _selectedLocation = loc);
          }),

          _chip("Date", _selectedDate != null, _pickDate),

          _chip(
            _sortMode == "date"
                ? (_sortAscending ? "Old → New" : "New → Old")
                : "Sort: Location",
            true,
            () {
              setState(() {
                if (_sortMode == "date") {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortMode = "date";
                  _sortAscending = false;
                }
              });
            },
          ),

          _chip("Clear", false, _clearFilters, color: Colors.redAccent),
        ],
      ),
    );
  }

  /// ------------------------------------------
  /// ITEM CARD UI
  /// ------------------------------------------
  Widget _itemCard(Map<String, dynamic> item) {
    // ✅ FIX: Read from the 'imageUrls' list, not 'imageUrl'
    final imageUrls =
        (item["imageUrls"] as List?)?.map((e) => e.toString()).toList() ?? [];
    final dt = (item["timestamp"] as Timestamp?)?.toDate();
    final dateStr = dt != null ? dt.toString().substring(0, 16) : "";

    // 🔥 FIX: ITEM NAME (support both formats)
    final String title =
        item["item_name"] ?? item["itemName"] ?? "Unnamed Item";

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          _ImageCarousel(imageUrls: imageUrls),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE + STATUS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item["source"] == "LOST"
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item["source"] ?? "",
                        style: TextStyle(
                          color: item["source"] == "LOST"
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(item["location"] ?? ""),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(Icons.schedule, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(dateStr),
                  ],
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // ✅ FIX: Pass required data to ChatPage
                    onPressed: () async {
                      // Prompt user to log in if they are not already.
                      if (!AuthService.isLoggedIn) {
                        final loggedIn = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const login.LoginScreen(),
                          ),
                        );
                        // If user cancels or fails login, do nothing.
                        if (loggedIn != true) return;
                      }

                      // Prevent user from chatting with themselves.
                      if (AuthService.currentUser?.uid == item['uid']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("This is your own post."),
                          ),
                        );
                        return;
                      }

                      // ✅ FIX: Add a null-check for the receiver's UID.
                      // This prevents crashes if old data in Firestore is missing the 'uid' field.
                      final receiverUid = item['uid'];
                      if (receiverUid == null ||
                          receiverUid.toString().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Cannot start chat. Poster information is missing.",
                            ),
                          ),
                        );
                        return;
                      }

                      // Navigate to chat, passing the required IDs and context.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            receiverId: receiverUid.toString(),
                            itemContext: 'Regarding: $title',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      item["source"] == "LOST"
                          ? "Chat with Finder"
                          : "Chat with Owner",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ------------------------------------------
  /// FILTER CHIP
  /// ------------------------------------------
  Widget _chip(String label, bool active, VoidCallback onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        selectedColor: kPrimary,
        labelStyle: TextStyle(color: active ? Colors.white : Colors.black),
        onSelected: (_) => onTap(),
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }
}

/// A swipeable image carousel with navigation arrows and page indicators.
class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const _ImageCarousel({required this.imageUrls});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    // If only one image, just show it without the carousel controls.
    if (widget.imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          widget.imageUrls.first,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox(
            height: 180,
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (_, index) {
                return Image.network(
                  widget.imageUrls[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),

            // Navigation Arrows
            Positioned(
              left: 0,
              child: IconButton(
                onPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white70,
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                onPressed: () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
              ),
            ),

            // Dots Indicator
            Positioned(
              bottom: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imageUrls.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    height: 8.0,
                    width: _currentPage == index ? 24.0 : 8.0,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
