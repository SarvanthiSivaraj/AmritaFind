// home_page.dart
// Full updated file — per-chip small "X" clear buttons (Option A)

import 'package:flutter/material.dart';
import 'post_item_form_page.dart';
import 'chat_page.dart';
import 'profile_page.dart';
import 'chat_bot_page.dart';
import 'login_page.dart' as login;
import '../services/auth_service.dart';

/// COLORS SHARED
const Color kPrimary = Color(0xFF8C2F39);
const Color kPrimaryChat = Color(0xFF8D303B);
const Color kBackgroundLight = Color(0xFFFAF9F6);
const Color kBackgroundDark = Color(0xFF1E1415);

class HomePageFeed extends StatefulWidget {
  const HomePageFeed({super.key});

  @override
  State<HomePageFeed> createState() => _HomePageFeedState();
}

class _HomePageFeedState extends State<HomePageFeed> {
  // status filter: 'all' / 'lost' / 'found'
  String _statusFilter = 'all';

  // sort mode: 'date' or 'location'
  String _sortMode = 'date';
  bool _sortAscending = false; // true = ascending (old->new for date, natural order for location)

  // selected filters
  DateTime? _selectedDate; // single-date filter chosen by user
  String? _selectedLocationFilter; // single location selected (e.g., 'AB1')

  // canonical location order used for sorting
  final List<String> _locationOrderCanonical = [
    'AB1',
    'AB2',
    'AB3',
    'NB1',
    'NB2',
    'NB3',
    'AUDITORIUM',
    'LIB',
    'CANTEEN',
    'PARKING'
  ];

  // available locations shown to user for filtering
  final List<String> _availableLocations = ['AB1', 'AB2', 'AB3', 'NB1', 'NB2', 'NB3', 'Auditorium', 'Lib', 'Canteen', 'Parking'];

  // sample items (in real app replace with backend data)
  late List<Map<String, dynamic>> _items = [
    {
      'id': 1,
      'title': 'Blue Water Bottle',
      'status': 'FOUND',
      'statusColorBg': Colors.green.shade100,
      'statusColorText': Colors.green.shade700,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCtbHje8XodJ39bsiJP6sMe2OeIbG6fmqzgVsRg4wEUEbBCPtUdhiSvBfXZhJ90t5TM-QRwL8gXByAzWBI2hQ6x8-1Zw4yXyAmuszB6qHJEk86dEP1i7aGkUEByY1VrNwa6ii-TTfsae8hM1cYteBVfPOZvRU6E5XsfwsZDH7zUYOlTpl1UTTtYR2BSKHK1MeWCHILoZN82kv54uCMNtZho7I36C2Cx8KhebJTq7s1_IksNaAf_QZ-Tx6T4Z_aso0w8P-5WbR5l5BhU',
      'location': 'Found near AB1 entrance',
      'time': 'Oct 26, 2:30 PM',
      'date': DateTime(2024, 10, 26, 14, 30),
      'buttonText': 'Chat with Finder',
    },
    {
      'id': 2,
      'title': 'Dell Laptop Charger',
      'status': 'LOST',
      'statusColorBg': Colors.red.shade100,
      'statusColorText': Colors.red.shade700,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBGnfrW4cBlo8roobNYq-sMBBuokYQtremQ7vhgJq3sQFz0oTIOLAzMDVVhWBYl3YFjv6E312WZ5yUwNngMJ98dLImIkVnyRGZoPBqjttj8oa_1Gk79t6RqjUOYozet2p3v1ekVmPFEpTd1XL289YyUjIJOUudbFQ0oTuzwNar41JP2jZRwTH2xAS8KSaG4TokgfzvsNlzpi76JwSCgpUNeuNWWJrYBVY2rez6qnFGBNG97RxuHM6xDnM-uzc3f89YnDahLUBkv_at4',
      'location': 'Lost in Central Library, 3rd floor',
      'time': 'Oct 26, 11:00 AM',
      'date': DateTime(2024, 10, 26, 11, 0),
      'buttonText': 'Chat with Owner',
    },
    {
      'id': 3,
      'title': 'Student ID Card',
      'status': 'FOUND',
      'statusColorBg': Colors.green.shade100,
      'statusColorText': Colors.green.shade700,
      'imageUrl':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuC0S-lgRPy0ijtWZ0y_9b5vmCRuvkqp3tIp0cgcuPMyEuJelS3XLpFp04jp5tY7oeGIaCV9EnKUFnFROziFrxUtXpWQ7rDlRz74BPU44RGjXEFeh5z4_exEuFUoevnZZ6I7MXgSDxOVfj-8HMAF3n3VaNEX1Ig_kf4aBT00e0lyMSSg4zfOeG1WNGyDHen3L_WslRUtlHPVrWx6Z5UN9NKTW55dabkTjPXrIP2VStSYxiFKvacxEl6u1nAmhSmeu-oIyy8JLkhZsgVP',
      'location': 'Found in college main auditorium',
      'time': 'Oct 25, 5:00 PM',
      'date': DateTime(2024, 10, 25, 17, 0),
      'buttonText': 'Chat with Finder',
    },
  ];

  // -------------------------
  // Helpers: extract & compare location keys
  // -------------------------
  // Normalize location names (e.g., 'Found near AB1 entrance' -> 'AB1', 'Central Library' -> 'LIB')
  String _extractLocationKey(String fullLocation) {
    final s = fullLocation.trim();

    // find tokens like AB1, AB-1, NB2 etc.
    final reg = RegExp(r'([A-Za-z]{2})[-\s]?(\d+)', caseSensitive: false);
    final m = reg.firstMatch(s);
    if (m != null) {
      final letters = m.group(1)!.toUpperCase();
      final digits = m.group(2)!;
      return '$letters$digits';
    }

    final lower = s.toLowerCase();
    if (lower.contains('parking')) return 'PARKING';
    if (lower.contains('canteen')) return 'CANTEEN';
    if (lower.contains('library') || lower.contains('lib')) return 'LIB';
    if (lower.contains('auditorium')) return 'AUDITORIUM';
    if (lower.contains('entrance')) return 'ENTRANCE';

    // fallback: take first word uppercased
    return s.split(' ').first.toUpperCase();
  }

  // Compare two normalized location keys using canonical order; fallback alphabetical.
  int _compareLocationKeys(String aRaw, String bRaw) {
    final a = aRaw.toUpperCase();
    final b = bRaw.toUpperCase();
    final idxA = _locationOrderCanonical.indexOf(a);
    final idxB = _locationOrderCanonical.indexOf(b);

    if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
    if (idxA != -1) return -1; // known first
    if (idxB != -1) return 1;
    return a.compareTo(b); // fallback alphabetical
  }

  // -------------------------
  // Compute visible items (filters + sort)
  // -------------------------
  List<Map<String, dynamic>> get _filteredAndSortedItems {
    var items = List<Map<String, dynamic>>.from(_items);

    // status filter
    if (_statusFilter == 'lost') {
      items = items.where((it) => it['status'] == 'LOST').toList();
    } else if (_statusFilter == 'found') {
      items = items.where((it) => it['status'] == 'FOUND').toList();
    }

    // date filter (single date chosen by user) - compare calendar day
    if (_selectedDate != null) {
      items = items.where((it) {
        final d = it['date'] as DateTime;
        return d.year == _selectedDate!.year && d.month == _selectedDate!.month && d.day == _selectedDate!.day;
      }).toList();
    }

    // location filter (single selected location)
    if (_selectedLocationFilter != null) {
      items = items.where((it) {
        final key = _extractLocationKey(it['location'] as String);
        return key.toUpperCase() == _selectedLocationFilter!.toUpperCase();
      }).toList();
    }

    // Sorting
    if (_sortMode == 'date') {
      // _sortAscending true => oldest->newest ; false => newest->oldest
      items.sort((a, b) {
        final da = a['date'] as DateTime;
        final db = b['date'] as DateTime;
        return _sortAscending ? da.compareTo(db) : db.compareTo(da);
      });
    } else if (_sortMode == 'location') {
      items.sort((a, b) {
        final la = _extractLocationKey(a['location'] as String);
        final lb = _extractLocationKey(b['location'] as String);
        final cmp = _compareLocationKeys(la, lb);
        return _sortAscending ? cmp : -cmp;
      });
    }

    return items;
  }

  // -------------------------
  // UI actions: pick date & pick location
  // -------------------------
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      helpText: 'Filter by date',
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // switch to date sort mode to make ordering obvious
        _sortMode = 'date';
      });
    }
  }

  Future<void> _pickLocationFilter(BuildContext context) async {
    final picked = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: const Text('Filter by location'),
          children: [
            SimpleDialogOption(
              child: const Text('All locations'),
              onPressed: () => Navigator.pop(ctx, null),
            ),
            ..._availableLocations.map((loc) {
              return SimpleDialogOption(
                child: Text(loc),
                onPressed: () => Navigator.pop(ctx, loc),
              );
            }),
          ],
        );
      },
    );

    // set selection (picked can be null to clear)
    setState(() {
      _selectedLocationFilter = picked;
    });
  }

  // Toggle sort mode between date/location (and manage default ascend/descend)
  void _toggleSortMode(String mode) {
    setState(() {
      if (_sortMode == mode) {
        _sortAscending = !_sortAscending;
      } else {
        _sortMode = mode;
        // sensible defaults:
        _sortAscending = mode == 'location' ? true : false; // location natural order, date newest-first
      }
    });
  }

  // Clear filters
  void _clearFilters() {
    setState(() {
      _statusFilter = 'all';
      _selectedDate = null;
      _selectedLocationFilter = null;
      _sortMode = 'date';
      _sortAscending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardLight = const Color(0xFFFFFFFF);
    final textPrimaryLight = const Color(0xFF333333);
    final textSecondaryLight = const Color(0xFF757575);
    final chipLight = const Color(0xFFF0EBEA);

    final bgColor = kBackgroundLight;
    final cardColor = cardLight;
    final textPrimary = textPrimaryLight;
    final textSecondary = textSecondaryLight;
    final chipColor = chipLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withOpacity(0.8),
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            Icon(Icons.school, color: kPrimary, size: 28),
            const SizedBox(width: 8),
            Text('Lost & Found', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble, color: kPrimary, size: 28),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatbotScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.person, color: kPrimary, size: 28),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear filters',
            onPressed: _clearFilters,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        onPressed: () async {
          if (AuthService.isLoggedIn) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PostItemFormPage()));
            return;
          }
          final result = await Navigator.of(context).push<bool?>(MaterialPageRoute(builder: (_) => const login.LoginScreen()));
          if (result == true || AuthService.isLoggedIn) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PostItemFormPage()));
          }
        },
        child: const Icon(Icons.add, size: 28),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          // search bar (not wired to filtering here)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search for 'water bottle', 'ID card'...",
                        hintStyle: TextStyle(color: textSecondary),
                      ),
                      style: TextStyle(color: textPrimary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // Filter chips row (status, location filter, date picker, sort mode toggles)
          SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip.withIcon(
                  label: 'All',
                  icon: Icons.filter_none,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                  selected: _statusFilter == 'all',
                  onTap: () => setState(() => _statusFilter = 'all'),
                ),

                _FilterChip.withIcon(
                  label: 'Lost',
                  icon: Icons.report,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                  selected: _statusFilter == 'lost',
                  onTap: () => setState(() => _statusFilter = 'lost'),
                  onClear: _statusFilter == 'lost' ? () => setState(() => _statusFilter = 'all') : null,
                ),

                _FilterChip.withIcon(
                  label: 'Found',
                  icon: Icons.check_circle,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                  selected: _statusFilter == 'found',
                  onTap: () => setState(() => _statusFilter = 'found'),
                  onClear: _statusFilter == 'found' ? () => setState(() => _statusFilter = 'all') : null,
                ),

                // Inline Clear chip (appears when any filter is active)
                if (_statusFilter != 'all' || _selectedDate != null || _selectedLocationFilter != null)
                  _FilterChip.withIcon(
                    label: 'Clear',
                    icon: Icons.clear,
                    chipColor: chipColor,
                    textPrimary: textPrimary,
                    selected: false,
                    onTap: () {
                      // capture previous state for undo
                      final prevStatus = _statusFilter;
                      final prevDate = _selectedDate;
                      final prevLoc = _selectedLocationFilter;
                      final prevSortMode = _sortMode;
                      final prevSortAsc = _sortAscending;

                      setState(() {
                        _statusFilter = 'all';
                        _selectedDate = null;
                        _selectedLocationFilter = null;
                        _sortMode = 'date';
                        _sortAscending = false;
                      });

                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Filters cleared'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              setState(() {
                                _statusFilter = prevStatus;
                                _selectedDate = prevDate;
                                _selectedLocationFilter = prevLoc;
                                _sortMode = prevSortMode;
                                _sortAscending = prevSortAsc;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),

                // Location filter (opens modal list to choose a location to filter)
                _FilterChip.withIcon(
                  label: _selectedLocationFilter == null ? 'Location' : 'Loc: ${_selectedLocationFilter!}',
                  icon: _selectedLocationFilter == null ? Icons.place : Icons.location_on,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                  selected: _selectedLocationFilter != null,
                  onTap: () => _pickLocationFilter(context),
                  onClear: _selectedLocationFilter != null
                      ? () {
                          setState(() {
                            _selectedLocationFilter = null;
                          });
                        }
                      : null,
                ),

                // Date picker chip (pick single date)
                _FilterChip.withIcon(
                  label: _selectedDate == null ? 'Date' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  icon: _selectedDate == null ? Icons.schedule : Icons.calendar_today,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                  selected: _selectedDate != null,
                  onTap: () => _pickDate(context),
                  onClear: _selectedDate != null
                      ? () {
                          setState(() {
                            _selectedDate = null;
                          });
                        }
                      : null,
                ),

                // Sort-by-location toggle (tap to switch to location sorting, tap again to toggle direction)
                _FilterChip.withIcon(
                  label: _sortMode == 'location' ? (_sortAscending ? 'Loc A→Z' : 'Loc Z→A') : 'Sort: Location',
                  icon: _sortMode == 'location' ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.sort_by_alpha,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                  selected: _sortMode == 'location',
                  onTap: () => _toggleSortMode('location'),
                  onClear: _sortMode == 'location'
                      ? () => setState(() {
                            _sortMode = 'date';
                            _sortAscending = false;
                          })
                      : null,
                ),

                // Sort-by-date toggle
                _FilterChip.withIcon(
                  label: _sortMode == 'date' ? (_sortAscending ? 'Date Old→New' : 'Date New→Old') : 'Sort: Date',
                  icon: _sortMode == 'date' ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.schedule,
                  chipColor: chipColor,
                  textPrimary: textPrimary,
                  selected: _sortMode == 'date',
                  onTap: () => _toggleSortMode('date'),
                  onClear: _sortMode == 'date'
                      ? () => setState(() {
                            _sortMode = 'location';
                            _sortAscending = true;
                          })
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Cards (generated from filtered & sorted items)
          ..._filteredAndSortedItems.map((item) {
            return _ItemCard(
              title: item['title'],
              statusText: item['status'],
              statusColorBg: item['statusColorBg'],
              statusColorText: item['statusColorText'],
              imageUrl: item['imageUrl'],
              location: item['location'],
              time: item['time'],
              buttonText: item['buttonText'],
              cardColor: cardColor,
              primary: kPrimary,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
              onChatPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatPage()));
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}

/// Filter chip widgets (Option A small X at right)
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final Color chipColor;
  final Color textPrimary;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onClear; // new: optional clear callback (renders small X at right)

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.primary,
    required this.chipColor,
    required this.textPrimary,
    this.icon,
    this.onTap,
    this.onClear,
  });

  const _FilterChip.withIcon({
    required this.label,
    required this.chipColor,
    required this.textPrimary,
    required IconData this.icon,
    required bool this.selected,
    this.onTap,
    this.onClear,
  }) : primary = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? primary : chipColor;
    final textColor = selected ? Colors.white : textPrimary;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 6),
                  Icon(icon, color: textColor, size: 16),
                ],
                // SMALL X ICON WHEN APPLICABLE (Option A appearance)
                if (onClear != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onClear,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      child: Icon(Icons.close, size: 14, color: textColor),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Item card (kept from your original)
class _ItemCard extends StatelessWidget {
  final String title;
  final String statusText;
  final Color statusColorBg;
  final Color statusColorText;
  final String imageUrl;
  final String location;
  final String time;
  final String buttonText;
  final Color cardColor;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onChatPressed;

  const _ItemCard({
    required this.title,
    required this.statusText,
    required this.statusColorBg,
    required this.statusColorText,
    required this.imageUrl,
    required this.location,
    required this.time,
    required this.buttonText,
    required this.cardColor,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.onChatPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: statusColorBg, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          statusText,
                          style: TextStyle(color: statusColorText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 18, color: textSecondary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(location, style: TextStyle(color: textSecondary, fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 18, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(time, style: TextStyle(color: textSecondary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onChatPressed,
                      style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: Text(buttonText, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
