import 'package:flutter_test/flutter_test.dart';
import 'package:audi_reproductor/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const AudiReproductorApp());
    expect(find.text('AUDI PLAYER'), findsOneWidget);
  });
}