import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khatmah/app.dart';
import 'package:khatmah/core/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App builds with Arabic default and shows the khatma tab',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const KhatmahApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Arabic is the default locale → the khatma screen title is "ختماتي".
    expect(find.text('ختماتي'), findsWidgets);
  });
}
