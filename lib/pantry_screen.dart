import 'package:flutter/material.dart';
import '../models/pantry_item.dart';

class PantryScreen extends StatefulWidget {
  final List<PantryItem> items;

  const PantryScreen({super.key, required this.items});

  @override
  _PantryScreenState createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String _searchQuery = '';
  bool _orderByExpiration = true;

  List<PantryItem> get _filteredItems {
    final filtered = widget.items
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    if (_orderByExpiration) {
      filtered.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    } else {
      filtered.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return filtered;
  }

  double _calculateProgress(PantryItem item) {
    final daysLeft = item.expirationDate.difference(DateTime.now()).inDays;
    if (daysLeft >= 30) return 0.0;
    if (daysLeft <= 1) return 1.0;
    return (30 - daysLeft) / 29;
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1) return Colors.deepPurple;
    if (progress <= 0.5) {
      return Color.lerp(Colors.green, Colors.yellow, progress * 2)!;
    } else {
      return Color.lerp(Colors.yellow, Colors.red, (progress - 0.5) * 2)!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pantry')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSearchAndSort(),
            const SizedBox(height: 12),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndSort() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('searchField'), // ADDED
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          key: const Key('sortButton'), // ADDED
          icon: Icon(
            _orderByExpiration ? Icons.calendar_today : Icons.sort_by_alpha,
            size: 28,
          ),
          tooltip: _orderByExpiration
              ? 'Order by expiration'
              : 'Order alphabetically',
          onPressed: () =>
              setState(() => _orderByExpiration = !_orderByExpiration),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      itemCount: _filteredItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final progress = _calculateProgress(item);

        return PantryItemCard(
          key: Key('item_$index'), // ADDED
          item: item,
          progress: progress,
          color: _getProgressColor(progress),
        );
      },
    );
  }
}

class PantryItemCard extends StatelessWidget {
  final PantryItem item;
  final double progress;
  final Color color;

  const PantryItemCard({
    super.key,
    required this.item,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final daysLeft = item.expirationDate.difference(DateTime.now()).inDays;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top colored strip
          Container(
            height: 6,
            key: Key('item_color_${item.name}'), // ADDED
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: item.imagePath != null
                ? Image.asset(item.imagePath!, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.fastfood,
                        size: 48, color: Colors.grey),
                  ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  key: Key('item_name_${item.name}'), // ADDED
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    key: Key('item_progress_${item.name}'), // ADDED
                    value: progress,
                    minHeight: 8,
                    color: color,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  daysLeft >= 0
                      ? '$daysLeft days left'
                      : 'Expired',
                  key: Key('item_days_${item.name}'), // ADDED
                  style: const TextStyle(
                      fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}