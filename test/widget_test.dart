// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:publi_calc/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('exibe o calculador de orçamento', (WidgetTester tester) async {
    await tester.pumpWidget(const McGlobalApp());

    expect(find.text('Monte o seu serviço'), findsOneWidget);
    expect(find.text('Adicionar ao orçamento'), findsOneWidget);
    expect(find.text('Configurar produtos'), findsOneWidget);
  });

  test('adiciona, remove e persiste produtos no catálogo', () async {
    SharedPreferences.setMockInitialValues({});

    final catalog = ProductCatalog();
    await catalog.load();

    final category = catalog.categories.first;
    final initialCount = category.products.length;

    await catalog.addProduct(
      categoryName: category.name,
      name: 'Produto teste',
      price: 1234,
      formula: 'teste',
    );

    expect(category.products.length, initialCount + 1);
    final inserted = category.products.last;
    expect(inserted.name, 'Produto teste');
    expect(inserted.price, 1234);

    await catalog.removeProduct(product: inserted);
    expect(category.products.length, initialCount);

    final reloaded = ProductCatalog();
    await reloaded.load();
    expect(reloaded.categories.first.products.length, initialCount);
  });
}
