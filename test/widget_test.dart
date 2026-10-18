import 'package:abyssinia_learn/app.dart';
import 'package:abyssinia_learn/data/repositories/auth_repository.dart';
import 'package:abyssinia_learn/data/services/storage_service.dart';
import 'package:abyssinia_learn/presentation/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows login screen when signed out', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final auth = AuthProvider(AuthRepository(storage));
    await auth.initialize();

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: const AbyssiniaLearnApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}