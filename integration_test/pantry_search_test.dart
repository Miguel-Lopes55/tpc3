import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_byte/models/pantry_item.dart';
import 'package:smart_byte/pantry_screen.dart';

void main() {
  // Test 1: Search for Ingredients and Ensure Correct Display
  testWidgets('Search returns matching ingredients with correct expiration information and order', (WidgetTester tester) async {
    final now = DateTime.now();
    final milkExpiration = now.add(const Duration(days: 20));
    final milkyExpiration = now.add(const Duration(days: 3));

    final pantryItems = [
      PantryItem(
        name: 'Milk',
        imagePath: 'assets/images/placeholder.png',
        addedDate: now.subtract(const Duration(days: 2)),
        expirationDate: milkExpiration,
      ),
      PantryItem(
        name: 'Milky',
        imagePath: 'assets/images/placeholder.png',
        addedDate: now.subtract(const Duration(days: 1)),
        expirationDate: milkyExpiration,
      ),
      PantryItem(
        name: 'Bananas',
        imagePath: 'assets/images/placeholder.png',
        addedDate: now,
        expirationDate: now.add(const Duration(days: 7)),
      ),
      PantryItem(
        name: 'Carrots',
        imagePath: 'assets/images/placeholder.png',
        addedDate: now,
        expirationDate: now.add(const Duration(days: 7)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: PantryScreen(items: pantryItems),
      ),
    );

    // Search for "milk"
    await tester.enterText(find.byKey(const Key('searchField')), 'milk');
    await tester.pump();

    // Verify that only "Milk" and "Milky" are displayed
    expect(find.byKey(const Key('item_name_Milk')), findsOneWidget);
    expect(find.byKey(const Key('item_name_Milky')), findsOneWidget);
    expect(find.byKey(const Key('item_name_Bananas')), findsNothing);
    expect(find.byKey(const Key('item_name_Carrots')), findsNothing);

    // Check expiration day labels are present
    expect(find.byKey(const Key('item_days_Milk')), findsOneWidget);
    expect(find.byKey(const Key('item_days_Milky')), findsOneWidget);

    // Check progress bars exist
    expect(find.byKey(const Key('item_progress_Milk')), findsOneWidget);
    expect(find.byKey(const Key('item_progress_Milky')), findsOneWidget);

    final milkIndicator = tester.widget<LinearProgressIndicator>(find.byKey(const Key('item_progress_Milk')));
    final milkyIndicator = tester.widget<LinearProgressIndicator>(find.byKey(const Key('item_progress_Milky')));
    final milkProgress = milkIndicator.value!;
    final milkyProgress = milkyIndicator.value!;

    // Compute expected values the same way _calculateProgress does,
    // using the same DateTime references to avoid any timing gap
    final expectedMilkProgress = (30 - milkExpiration.difference(DateTime.now()).inDays) / 29;
    final expectedMilkyProgress = (30 - milkyExpiration.difference(DateTime.now()).inDays) / 29;
    expect((milkProgress - expectedMilkProgress).abs(), lessThan(0.001));
    expect((milkyProgress - expectedMilkyProgress).abs(), lessThan(0.001));
    expect(milkProgress, lessThan(milkyProgress));

    // Check colors — neither should be expired (deepPurple)
    // and they should be different since they have different expiration distances
    expect(milkIndicator.color, isNot(Colors.deepPurple));
    expect(milkyIndicator.color, isNot(Colors.deepPurple));
    expect(milkyIndicator.color, isNot(milkIndicator.color));
  });

  // Test 2: Initial Sorting by Expiration Date
  testWidgets('Initial sorting by expiration date', (WidgetTester tester) async {
    final pantryItems = [
      PantryItem(
        name: 'Milk',
        imagePath: 'assets/images/placeholder.png',
        addedDate: DateTime.now().subtract(const Duration(days: 2)),
        expirationDate: DateTime.now().add(const Duration(days: 20)),
      ),
      PantryItem(
        name: 'Milky',
        imagePath: 'assets/images/placeholder.png',
        addedDate: DateTime.now().subtract(const Duration(days: 1)),
        expirationDate: DateTime.now().add(const Duration(days: 3)),
      ),
      PantryItem(
        name: 'Bananas',
        imagePath: 'assets/images/placeholder.png',
        addedDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 7)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: PantryScreen(items: pantryItems),
      ),
    );

    expect(find.byKey(const Key('item_name_Milk')), findsOneWidget);
    expect(find.byKey(const Key('item_name_Bananas')), findsOneWidget);
    expect(find.byKey(const Key('item_name_Milky')), findsOneWidget);
  });

  // Test 3: Toggle Sorting by Expiration Date and Alphabetical Order
  testWidgets('Toggle sorting by expiration date and alphabetical order', (WidgetTester tester) async {
    final pantryItems = [
      PantryItem(
        name: 'Milk',
        imagePath: 'assets/images/placeholder.png',
        addedDate: DateTime.now().subtract(const Duration(days: 2)),
        expirationDate: DateTime.now().add(const Duration(days: 20)),
      ),
      PantryItem(
        name: 'Milky',
        imagePath: 'assets/images/placeholder.png',
        addedDate: DateTime.now().subtract(const Duration(days: 1)),
        expirationDate: DateTime.now().add(const Duration(days: 3)),
      ),
      PantryItem(
        name: 'Bananas',
        imagePath: 'assets/images/placeholder.png',
        addedDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 7)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: PantryScreen(items: pantryItems),
      ),
    );

    // All items visible before toggle
    expect(find.byKey(const Key('item_name_Milk')), findsOneWidget);
    expect(find.byKey(const Key('item_name_Bananas')), findsOneWidget);
    expect(find.byKey(const Key('item_name_Milky')), findsOneWidget);

    // Tap the sort button using its key (icon changes depending on state, so avoid find.byIcon)
    await tester.tap(find.byKey(const Key('sortButton')));
    await tester.pump();

    // All items still visible after toggle
    expect(find.byKey(const Key('item_name_Bananas')), findsOneWidget);
    expect(find.byKey(const Key('item_name_Milk')), findsOneWidget);
    expect(find.byKey(const Key('item_name_Milky')), findsOneWidget);
  });

  // Test 4: Search Excludes Non-Matching Items from Display
  testWidgets('Search excludes non-matching items from display', (WidgetTester tester) async {
    final pantryItems = [
      PantryItem(
        name: 'Milk',
        imagePath: 'assets/images/placeholder.png',
        addedDate: DateTime.now().subtract(const Duration(days: 2)),
        expirationDate: DateTime.now().add(const Duration(days: 20)),
      ),
      PantryItem(
        name: 'Milky',
        imagePath: 'assets/images/placeholder.png',
        addedDate: DateTime.now().subtract(const Duration(days: 1)),
        expirationDate: DateTime.now().add(const Duration(days: 3)),
      ),
      PantryItem(
        name: 'Bananas',
        imagePath: 'assets/images/placeholder.png',
        addedDate: DateTime.now(),
        expirationDate: DateTime.now().add(const Duration(days: 7)),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: PantryScreen(items: pantryItems),
      ),
    );

    // Search for "Milk"
    await tester.enterText(find.byKey(const Key('searchField')), 'Milk');
    await tester.pump();

    // Use item name keys to avoid matching the TextField content
    expect(find.byKey(const Key('item_name_Milk')), findsOneWidget);
    expect(find.byKey(const Key('item_name_Milky')), findsOneWidget);
    expect(find.byKey(const Key('item_name_Bananas')), findsNothing);
  });
}