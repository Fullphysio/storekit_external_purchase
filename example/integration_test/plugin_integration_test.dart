// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:storekit_external_purchase/storekit_external_purchase.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('canMakePayments test', (WidgetTester tester) async {
    final StorekitExternalPurchase plugin = StorekitExternalPurchase();
    final bool canMakePayments = await plugin.canMakePayments();
    // The test should pass as long as the method doesn't throw an exception
    expect(canMakePayments, isA<bool>());
  });
}
