import 'package:flutter_test/flutter_test.dart';
import 'package:zen_gps_tracker/main.dart';

void main() {
  testWidgets('ZenGpsApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ZenGpsApp());
    expect(find.text('ZEN GPS'), findsOneWidget);
  });
}
