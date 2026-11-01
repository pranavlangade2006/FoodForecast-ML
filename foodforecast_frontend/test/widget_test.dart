import 'package:flutter_test/flutter_test.dart';
import 'package:foodforecast_frontend/main.dart';

void main() {
  testWidgets('FoodForecast ML dashboard loads correctly', (
    WidgetTester tester,
  ) async {
    // Open the FoodForecast ML application.
    await tester.pumpWidget(const FoodForecastApp());

    // Verify the dashboard and its main sections.
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Demand prediction'), findsOneWidget);
    expect(find.text('Material requirements'), findsOneWidget);

    // Verify the customer input fields.
    expect(find.text('Expected customers'), findsOneWidget);
    expect(find.text('Reservations'), findsOneWidget);
    expect(find.text('Previous-day customers'), findsOneWidget);

    // Verify the raw materials.
    expect(find.text('Rice'), findsOneWidget);
    expect(find.text('Potato'), findsOneWidget);
    expect(find.text('Onion'), findsOneWidget);
    expect(find.text('Tomato'), findsOneWidget);
    expect(find.text('Cooking oil'), findsOneWidget);
    expect(find.text('Flour'), findsOneWidget);
  });
}
