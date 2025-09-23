// lib/screens/explore_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UI එක හදන්න අපි තාවකාලික data ටිකක් පාවිච්චි කරමු
    final List<Map<String, String>> featuredDestinations = [
      {
        'image':
            'https://images.unsplash.com/photo-1588789214754-202b2aba513c?q=80&w=2574&auto=format&fit=crop',
        'title': 'Santorini, Greece',
        'description': 'A volcanic island in the Cyclades group.',
        'duration': '4d 3n',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?q=80&w=2670&auto=format&fit=crop',
        'title': 'Kyoto, Japan',
        'description': 'Known for its classical Buddhist temples.',
        'duration': '3d 2n',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1558035719-7d3d19b48f32?q=80&w=2574&auto=format&fit=crop',
        'title': 'Machu Picchu, Peru',
        'description': 'A 15th-century Inca citadel.',
        'duration': '5d 4n',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Explore',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildCategoryFilters(),
              const SizedBox(height: 24),
              const Text(
                'Featured destinations',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: featuredDestinations.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final dest = featuredDestinations[index];
                  return _buildDestinationCard(
                    dest['image']!,
                    dest['title']!,
                    dest['description']!,
                    dest['duration']!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: 'Where to?',
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['Beaches', 'Historical sites', 'Mountains', 'Forests'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ChoiceChip(
            label: Text(categories[index]),
            selected: index == 0, // Default selection
            onSelected: (selected) {},
            backgroundColor: Colors.grey[100],
            selectedColor: const Color(0xFF00A3FF).withOpacity(0.2),
            labelStyle: TextStyle(
              color: index == 0 ? const Color(0xFF00A3FF) : Colors.black,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: BorderSide.none,
          );
        },
      ),
    );
  }

  Widget _buildDestinationCard(
    String imageUrl,
    String title,
    String description,
    String duration,
  ) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Text Content
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      duration,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
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
