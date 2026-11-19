import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sample_garages.dart';
import '../models/garage.dart';
import '../state/bookings_controller.dart';
import '../state/saved_garages_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/garage_card.dart';
import '../widgets/garage_details_sheet.dart';
import '../widgets/garage_map.dart';
import 'map_tab.dart';
import 'profile_tab.dart';

class ParkingHomePage extends StatefulWidget {
  const ParkingHomePage({super.key});

  @override
  State<ParkingHomePage> createState() => _ParkingHomePageState();
}

class _ParkingHomePageState extends State<ParkingHomePage> {
  static const int _mapTab = 1;
  static const int _savedTab = 2;
  static const int _profileTab = 3;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  int _selectedTab = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  /// Garages for the current tab (all, or only saved) filtered by the search.
  List<Garage> _visibleGarages(SavedGaragesController saved) {
    final query = _searchQuery.toLowerCase();

    return sampleGarages.where((garage) {
      if (_selectedTab == _savedTab &&
          !saved.isSaved(garage)) {
        return false;
      }
      if (query.isEmpty) return true;

      return garage.name.toLowerCase().contains(query) ||
          garage.area.toLowerCase().contains(query) ||
          garage.type.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_selectedTab) {
          _profileTab => ProfileTab(onOpenSaved: () => _selectTab(_savedTab)),
          _mapTab => const MapTab(garages: sampleGarages),
          _ => _buildGarageList(),
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _selectTab,
        backgroundColor: Colors.white,
        indicatorColor: lightTeal,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildGarageList() {
    final saved = context.watch<SavedGaragesController>();
    final bookings = context.watch<BookingsController>();
    final garages = _visibleGarages(saved);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        _buildHeader(),
        const SizedBox(height: 30),
        const Text(
          'Find parking\nin Dubai',
          style: TextStyle(
            fontSize: 32,
            height: 1.2,
            fontWeight: FontWeight.bold,
            color: darkText,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Discover parking options near your destination.',
          style: TextStyle(fontSize: 14, color: secondaryText),
        ),
        const SizedBox(height: 24),
        _buildSearchField(),
        const SizedBox(height: 24),
        GarageMap(
          garages: garages,
          onGarageTap: (garage) => showGarageDetails(context, garage),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedTab == _savedTab
                    ? 'Saved parking'
                    : 'Parking locations',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
            ),
            Text(
              '${garages.length} found',
              style: const TextStyle(fontSize: 13, color: secondaryText),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (garages.isEmpty)
          _buildEmptyState()
        else
          for (final garage in garages)
            GarageCard(
              garage: garage,
              availableSpaces:
                  bookings.isLoaded ? bookings.freeSpaces(garage) : null,
              isSaved: saved.isSaved(garage),
              onTap: () => showGarageDetails(context, garage),
              onToggleSaved: () => saved.toggle(garage),
            ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            'Sample listings for demonstration only',
            style: TextStyle(color: secondaryText, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: primaryTeal,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.local_parking,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parking System',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Find your perfect parking spot',
                style: TextStyle(fontSize: 12, color: secondaryText),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon.')),
            );
          },
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search garage or area...',
        hintStyle: const TextStyle(color: secondaryText, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: primaryTeal),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.close),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, size: 42, color: secondaryText),
          SizedBox(height: 12),
          Text(
            'No parking locations found',
            style: TextStyle(fontWeight: FontWeight.w600, color: darkText),
          ),
          SizedBox(height: 6),
          Text(
            'Try another garage name or area.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryText),
          ),
        ],
      ),
    );
  }
}
