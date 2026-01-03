// Basic Flutter widget test for Bagour Delivery Driver App

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delivery_app/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      const ProviderScope(child: BagourDeliveryDriverApp()),
    );

    // Verify that the app starts
    expect(find.byType(BagourDeliveryDriverApp), findsOneWidget);
  });
}
