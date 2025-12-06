import 'package:flutter/material.dart';
import '../models/items.dart';
import '../data/items_dummy.dart';
import '../widgets/item_card.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/suggestion_box.dart';
import '../pages/detail_page.dart';
import '../pages/form_page.dart';
import '../pages/ai_chat_page.dart';
import '../pages/profile_page.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    HomePage(),
    AIChatPage(),
    ProfilePage(),
  ];

  void _openForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: IconButton(
          onPressed: _openForm,
          icon: const Icon(Icons.add_rounded, size: 28),
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNav(
        activeIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showFilters = false;
  DateTime? _filterDate;
  String _sortBy = 'Date';
  List<String> _suggestions = ['Wallet', 'Keys', 'Phone', 'Bag', 'Laptop'];
  ItemType _activeTab = ItemType.lost;
  int _navIndex = 0;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Item> get _filteredSorted {
  final base = itemsDummy.where((i) => i.type == (_activeTab == ItemType.lost ? ItemType.lost : ItemType.found));

  final filtered = base.where((i) {
    if (_filterDate != null) {
      return i.date.year == _filterDate!.year && i.date.month == _filterDate!.month && i.date.day == _filterDate!.day;
    }
    return true;
  }).toList();

  // Sorting: Date (newest first) or Place (A-Z)
  if (_sortBy == 'Date') {
    filtered.sort((a, b) => b.date.compareTo(a.date)); // newest first
  } else if (_sortBy == 'Place') {
    filtered.sort((a, b) => a.location.toLowerCase().compareTo(b.location.toLowerCase()));
  }

  return filtered;
}

  void _openDetail(Item item) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(item: item)));
  }

  void _openForm() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => FormPage()));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Professional Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Top Row
                  Row(
                    children: [
                      // Profile
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'U',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'User Name',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.notifications_none_rounded, size: 24),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    'Lost & Found',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find what you\'ve lost or help others',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search & Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 22),
                          hintText: 'Search items...',
                          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => setState(() => _showFilters = !_showFilters),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _showFilters ? const Color(0xFF6366F1) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _showFilters
                                ? const Color(0xFF6366F1).withOpacity(0.3)
                                : Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: _showFilters ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Filters
            if (_showFilters)
  Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row: Date picker + Sort chips (Place / Date)
        Row(
          children: [
            // Date picker button
            ElevatedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _filterDate = picked);
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(_filterDate == null
                  ? 'Date'
                  : '${_filterDate!.toLocal().toString().split(' ')[0]}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 12),

            // Sort chips
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Place chip
                  GestureDetector(
                    onTap: () => setState(() => _sortBy = 'Place'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _sortBy == 'Place' ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _sortBy == 'Place' ? const Color(0xFF556BFF) : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.place, size: 16, color: _sortBy == 'Place' ? const Color(0xFF556BFF) : Colors.grey),
                          const SizedBox(width: 8),
                          Text('Place', style: TextStyle(color: _sortBy == 'Place' ? const Color(0xFF556BFF) : Colors.grey[700], fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Date chip
                  GestureDetector(
                    onTap: () => setState(() => _sortBy = 'Date'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _sortBy == 'Date' ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _sortBy == 'Date' ? const Color(0xFF556BFF) : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: _sortBy == 'Date' ? const Color(0xFF556BFF) : Colors.grey),
                          const SizedBox(width: 8),
                          Text('Date', style: TextStyle(color: _sortBy == 'Date' ? const Color(0xFF556BFF) : Colors.grey[700], fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Optional: a small "Clear date filter" action when a date is selected
        if (_filterDate != null)
          Row(
            children: [
              Text('Filtered by: ${_filterDate!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => setState(() => _filterDate = null),
                child: const Text('Clear'),
              )
            ],
          ),
      ],
    ),
  ),
            const SizedBox(height: 16),
            // Quick Suggestions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SuggestionBox(
                suggestions: _suggestions,
                onSelect: (s) {
                  setState(() {
                    _searchController.text = s;
                    _searchQuery = s;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = ItemType.lost),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: _activeTab == ItemType.lost
                                ? const LinearGradient(
                                    colors: [Color(0xFFEF4444), Color(0xFFF97316)],
                                  )
                                : null,
                            color: _activeTab == ItemType.lost ? null : Colors.transparent,
                            boxShadow: _activeTab == ItemType.lost
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFEF4444).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Lost Items',
                              style: TextStyle(
                                color: _activeTab == ItemType.lost ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = ItemType.found),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: _activeTab == ItemType.found
                                ? const LinearGradient(
                                    colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                                  )
                                : null,
                            color: _activeTab == ItemType.found ? null : Colors.transparent,
                            boxShadow: _activeTab == ItemType.found
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Found Items',
                              style: TextStyle(
                                color: _activeTab == ItemType.found ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 2;
                    double childAspectRatio = 0.70;

                    if (constraints.maxWidth > 600) {
                      crossAxisCount = 3;
                      childAspectRatio = 0.72;
                    }
                    if (constraints.maxWidth > 900) {
                      crossAxisCount = 4;
                      childAspectRatio = 0.75;
                    }

                    return GridView.builder(
                      padding: EdgeInsets.only(bottom: bottomPadding + 80, top: 4),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: _filteredSorted.length,
                      itemBuilder: (context, index) {
                        final item = _filteredSorted[index];
                        return ItemCard(
                          item: item,
                          onTap: () => _openDetail(item),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: IconButton(
          onPressed: _openForm,
          icon: const Icon(Icons.add_rounded, size: 28),
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNav(
        activeIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

enum ItemType { lost, found }