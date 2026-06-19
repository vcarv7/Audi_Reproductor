import 'package:flutter_test/flutter_test.dart';
import 'package:eco_player/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const EcoApp());
    expect(find.text('ECO'), findsOneWidget);
  });
}