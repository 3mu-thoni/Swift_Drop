import 'package:flutter_test/flutter_test.dart';
import 'package:swiftdrop/main.dart';

void main() {
  testWidgets('SwiftDrop smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SwiftDropApp());
    expect(find.text('SwiftDrop'), findsOneWidget);
  });
}