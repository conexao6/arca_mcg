import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final catalog = ProductCatalog();
  await catalog.load();
  runApp(McGlobalApp(catalog: catalog));
}

const _pink = Color(0xFFD8006C);
const _red = Color(0xFFE30613);
const _blue = Color(0xFF00A0E9);
const _yellow = Color(0xFFFFED00);
final _money = NumberFormat('#,##0.00', 'pt_PT');

String kz(num value) => '${_money.format(value)} Kz';

class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    this.formula = '',
  });
  final String id;
  String name;
  double price;
  String type;
  String formula;
}

class ProductCategory {
  ProductCategory({required this.name, required this.products});
  String name;
  List<Product> products;
}

class ProductCatalog extends ChangeNotifier {
  ProductCatalog() {
    categories = _defaultCategories();
  }

  late List<ProductCategory> categories;
  static const _storageKey = 'product_catalog_v1';

  static List<ProductCategory> _defaultCategories() => [
    ProductCategory(
      name: 'Impressão & Adesivos',
      products: [
        Product(
          id: 'lona_normal',
          name: 'Lona Normal',
          price: 3500,
          type: 'm2',
          formula: 'largura × altura × preço × quantidade',
        ),
        Product(
          id: 'lona_estrutura',
          name: 'Lona com Estrutura',
          price: 15000,
          type: 'm2',
          formula: 'largura × altura × preço × quantidade',
        ),
        Product(
          id: 'vinil_normal',
          name: 'Vinil Normal',
          price: 3500,
          type: 'm2',
          formula: 'largura × altura × preço × quantidade',
        ),
        Product(
          id: 'vinil_perfurado',
          name: 'Vinil Perfurado',
          price: 5000,
          type: 'm2',
          formula: 'largura × altura × preço × quantidade',
        ),
        Product(
          id: 'vinil_recortado',
          name: 'Vinil Recortado',
          price: 10000,
          type: 'm2',
          formula: 'largura × altura × preço × quantidade',
        ),
        Product(
          id: 'vinil_fosco',
          name: 'Vinil Fosco',
          price: 6000,
          type: 'm2',
          formula: 'largura × altura × preço × quantidade',
        ),
      ],
    ),
    ProductCategory(
      name: 'Letras & Letreiros',
      products: [
        Product(
          id: 'letras_3d',
          name: 'Letras 3D',
          price: 700,
          type: 'letra_cm',
          formula: 'tamanho por letra × qtd. de letras × jogos',
        ),
        Product(
          id: 'letras_3d_luminosa',
          name: 'Letras 3D Luminosa',
          price: 1800,
          type: 'letra_cm',
          formula: 'tamanho por letra × qtd. de letras × jogos',
        ),
      ],
    ),
    ProductCategory(
      name: 'Placas Luminosas',
      products: [
        Product(
          id: 'placa_lona',
          name: 'Placa Luminosa com Lona',
          price: 95000,
          type: 'm2',
          formula: 'largura × altura × preço × quantidade',
        ),
        Product(
          id: 'placa_acrilico',
          name: 'Placa Luminosa com Acrílico',
          price: 120000,
          type: 'm2',
          formula: 'largura × altura × preço × quantidade',
        ),
      ],
    ),
    ProductCategory(
      name: 'Vestuário Personalizado',
      products: [
        Product(
          id: 'tshirt_clara',
          name: 'T-Shirt Clara',
          price: 3500,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'tshirt_escura',
          name: 'T-Shirt Escura',
          price: 4500,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'tshirt_tecido_diferente',
          name: 'T-Shirt Tecido Diferente',
          price: 5500,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'polo',
          name: 'Polo',
          price: 7000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'camisa',
          name: 'Camisa',
          price: 12000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
      ],
    ),
    ProductCategory(
      name: 'Coletes & Acessórios',
      products: [
        Product(
          id: 'colete_bordado',
          name: 'Colete Multibolso Bordado',
          price: 17000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'colete_estampado',
          name: 'Colete Multibolso Estampado',
          price: 15000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'colete_bord_estamp',
          name: 'Colete Multibolso Bordado/Estampado',
          price: 16000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'colete_refletor',
          name: 'Colete Refletor',
          price: 3000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'bone',
          name: 'Boné',
          price: 4000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
      ],
    ),
    ProductCategory(
      name: 'Sinalização & Impressos',
      products: [
        Product(
          id: 'placa_sinaletica',
          name: 'Placa Sinalética 30 cm',
          price: 2500,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'passe_pvc',
          name: 'Passe PVC Lado',
          price: 1500,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'cartao_visita',
          name: 'Cartão de Visita (100 Unidades)',
          price: 100,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'flyer_a6',
          name: 'Flyer A6',
          price: 300,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'agenda',
          name: 'Agenda',
          price: 8000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
      ],
    ),
    ProductCategory(
      name: 'Publicidade & Display',
      products: [
        Product(
          id: 'balcao',
          name: 'Balcão Personalizado',
          price: 60000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'rollup',
          name: 'Rollup',
          price: 45000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
      ],
    ),
    ProductCategory(
      name: 'Serviços Especiais',
      products: [
        Product(
          id: 'carimbo',
          name: 'Carimbo',
          price: 10000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
      ],
    ),
    ProductCategory(
      name: 'Cruz de Farmácia',
      products: [
        Product(
          id: 'cruz_tipo1',
          name: 'Cruz de Farmácia Tipo 1',
          price: 95000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'cruz_tipo2',
          name: 'Cruz de Farmácia Tipo 2',
          price: 250000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
        Product(
          id: 'cruz_tipo3',
          name: 'Cruz de Farmácia Tipo 3',
          price: 300000,
          type: 'qtd',
          formula: 'preço × quantidade',
        ),
      ],
    ),
  ];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      await save();
      return;
    }

    final decoded = raw.split('\n');
    if (decoded.length < 2) {
      return;
    }

    final loaded = <ProductCategory>[];
    for (final line in decoded) {
      if (line.isEmpty) continue;
      final parts = line.split('|');
      if (parts.length != 5) continue;
      final categoryName = parts[0];
      final productId = parts[1];
      final name = parts[2];
      final price = double.tryParse(parts[3]) ?? 0;
      final type = parts[4];
      final existingCategory = loaded
          .where((item) => item.name == categoryName)
          .firstOrNull;
      if (existingCategory == null) {
        loaded.add(ProductCategory(name: categoryName, products: []));
      }
      loaded
          .firstWhere((item) => item.name == categoryName)
          .products
          .add(
            Product(
              id: productId,
              name: name,
              price: price,
              type: type,
              formula: '',
            ),
          );
    }

    if (loaded.isNotEmpty) {
      categories = loaded;
      notifyListeners();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final buffer = StringBuffer();
    for (final category in categories) {
      for (final product in category.products) {
        buffer.writeln(
          '${category.name}|${product.id}|${product.name}|${product.price}|${product.type}',
        );
      }
    }
    await prefs.setString(_storageKey, buffer.toString());
  }

  bool containsProduct(Product product) {
    for (final category in categories) {
      if (category.products.any((item) => item.id == product.id)) {
        return true;
      }
    }
    return false;
  }

  Product? get firstProduct {
    for (final category in categories) {
      if (category.products.isNotEmpty) {
        return category.products.first;
      }
    }
    return null;
  }

  Future<void> updateProduct(
    Product product, {
    String? name,
    double? price,
    String? formula,
    String? type,
  }) async {
    if (name != null) product.name = name;
    if (price != null) product.price = price;
    if (formula != null) product.formula = formula;
    if (type != null) product.type = type;
    notifyListeners();
    await save();
  }

  Future<void> addProduct({
    required String categoryName,
    String? name,
    double? price,
    String? formula,
    String? type,
  }) async {
    final category = categories.firstWhere(
      (item) => item.name == categoryName,
      orElse: () => categories.first,
    );
    final newProduct = Product(
      id: 'novo_${DateTime.now().microsecondsSinceEpoch}',
      name: name ?? 'Novo produto',
      price: price ?? 0,
      type: type ?? 'qtd',
      formula: formula ?? 'preço × quantidade',
    );
    category.products.add(newProduct);
    notifyListeners();
    await save();
  }

  Future<void> removeProduct({required Product product}) async {
    for (final category in categories) {
      category.products.removeWhere((item) => item.id == product.id);
    }
    notifyListeners();
    await save();
  }
}

class QuoteItem {
  QuoteItem({
    required this.product,
    required this.quantity,
    required this.detail,
    required this.total,
  });
  final Product product;
  int quantity;
  final String detail;
  double total;
}

class McGlobalApp extends StatelessWidget {
  const McGlobalApp({super.key, this.catalog});

  final ProductCatalog? catalog;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => catalog ?? ProductCatalog(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PubliCalc',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _pink),
        fontFamily: 'Arial',
      ),
      home: const QuotePage(),
    ),
  );
}

class QuotePage extends StatefulWidget {
  const QuotePage({super.key});

  @override
  State<QuotePage> createState() => _QuotePageState();
}

class _QuotePageState extends State<QuotePage> {
  final _width = TextEditingController(text: '1');
  final _height = TextEditingController(text: '1');
  final _quantity = TextEditingController(text: '1');
  final _letterSize = TextEditingController(text: '10');
  final _letters = TextEditingController(text: '1');
  final _sets = TextEditingController(text: '1');
  final _client = TextEditingController();
  final _company = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  Product? _selected;
  final _items = <QuoteItem>[];

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  double get _preview {
    final selected = _selected;
    if (selected == null) return 0;
    if (selected.type == 'm2') {
      return _number(_width) *
          _number(_height) *
          selected.price *
          _number(_quantity);
    }
    if (selected.type == 'letra_cm') {
      return _number(_letterSize) *
          selected.price *
          _number(_letters) *
          _number(_sets);
    }
    return selected.price * _number(_quantity);
  }

  double get _total => _items.fold(0, (sum, item) => sum + item.total);

  @override
  void dispose() {
    for (final controller in [
      _width,
      _height,
      _quantity,
      _letterSize,
      _letters,
      _sets,
      _client,
      _company,
      _phone,
      _notes,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncSelection(ProductCatalog catalog) {
    if (_selected == null || !catalog.containsProduct(_selected!)) {
      _selected = catalog.firstProduct;
    }
  }

  void _addItem() {
    final selected = _selected;
    if (selected == null) return;
    final quantity = selected.type == 'letra_cm'
        ? _number(_letters).toInt()
        : _number(_quantity).toInt();
    if (_preview <= 0 || quantity <= 0) return;
    final detail = selected.type == 'm2'
        ? '${_width.text} m x ${_height.text} m · ${_quantity.text} un.'
        : selected.type == 'letra_cm'
        ? '${_letterSize.text} cm · ${_letters.text} letras · ${_sets.text} jogos'
        : '${_quantity.text} un.';
    setState(
      () => _items.add(
        QuoteItem(
          product: selected,
          quantity: quantity,
          detail: detail,
          total: _preview,
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, {String? suffix}) =>
      InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: const Color(0xFFF7F8FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _blue, width: 2),
        ),
      );

  Widget _field(
    String label,
    TextEditingController controller, {
    String? suffix,
  }) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    onChanged: (_) => setState(() {}),
    decoration: _decoration(label, suffix: suffix),
  );

  Widget _panel({
    required String title,
    required Widget child,
    IconData? icon,
  }) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: _pink),
              const SizedBox(width: 10),
            ],
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    ),
  );

  Widget _calculator(ProductCatalog catalog) => _panel(
    title: 'Monte o seu serviço',
    icon: Icons.tune_rounded,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductSettingsPage()),
            ),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Configurar produtos'),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<Product>(
          key: ValueKey(_selected?.id ?? 'none'),
          initialValue: _selected,
          isExpanded: true,
          decoration: _decoration('Produto ou serviço'),
          items: [
            for (final category in catalog.categories) ...[
              DropdownMenuItem<Product>(
                enabled: false,
                child: Text(
                  category.name.toUpperCase(),
                  style: const TextStyle(
                    color: _pink,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...category.products.map(
                (product) =>
                    DropdownMenuItem(value: product, child: Text(product.name)),
              ),
            ],
          ],
          onChanged: (product) {
            if (product != null) {
              setState(() => _selected = product);
            }
          },
        ),
        const SizedBox(height: 16),
        if (_selected?.type == 'm2') ...[
          Row(
            children: [
              Expanded(child: _field('Largura', _width, suffix: 'm')),
              const SizedBox(width: 12),
              Expanded(child: _field('Altura', _height, suffix: 'm')),
            ],
          ),
          const SizedBox(height: 12),
          _field('Quantidade', _quantity, suffix: 'un.'),
          const SizedBox(height: 14),
          _metric(
            'ÁREA TOTAL',
            '${(_number(_width) * _number(_height) * _number(_quantity)).toStringAsFixed(2)} m²',
            _blue,
          ),
        ] else if (_selected?.type == 'letra_cm') ...[
          Row(
            children: [
              Expanded(
                child: _field('Tamanho por letra', _letterSize, suffix: 'cm'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field('Qtd. de letras', _letters, suffix: 'un.'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field('Jogos / conjuntos', _sets, suffix: 'jogos'),
        ] else
          _field('Quantidade', _quantity, suffix: 'un.'),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _pink.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Parcial do item',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                kz(_preview),
                style: const TextStyle(
                  color: _pink,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar ao orçamento'),
          ),
        ),
      ],
    ),
  );

  Widget _metric(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );

  Widget _cart() => _panel(
    title: 'Orçamento atual',
    icon: Icons.receipt_long_rounded,
    child: _items.isEmpty
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: Center(
              child: Text('Adicione produtos para montar o orçamento.'),
            ),
          )
        : Column(
            children: [
              for (var index = 0; index < _items.length; index++)
                _cartItem(index),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL DO ORÇAMENTO',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    kz(_total),
                    style: const TextStyle(
                      color: _pink,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
  );

  Widget _cartItem(int index) {
    final item = _items[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: _blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  item.detail,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                kz(item.total),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Diminuir quantidade',
                    onPressed: item.quantity <= 1
                        ? null
                        : () => setState(() {
                            item.total =
                                item.total /
                                item.quantity *
                                (item.quantity - 1);
                            item.quantity--;
                          }),
                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                  ),
                  Text(
                    '${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    tooltip: 'Aumentar quantidade',
                    onPressed: () => setState(() {
                      item.total =
                          item.total / item.quantity * (item.quantity + 1);
                      item.quantity++;
                    }),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            tooltip: 'Remover item',
            onPressed: () => setState(() => _items.removeAt(index)),
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _clientPanel() => _panel(
    title: 'Dados do cliente',
    icon: Icons.person_outline_rounded,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _client,
                decoration: _decoration('Nome'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _company,
                decoration: _decoration('Empresa'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: _decoration('Telefone'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notes,
          maxLines: 3,
          decoration: _decoration('Observações'),
        ),
      ],
    ),
  );

  String _quoteText() =>
      '''MC GLOBAL PUBLICIDADES
Transformamos sua marca em destaque!
Luanda - Angola | +244 922 462 606

ORÇAMENTO
Cliente: ${_client.text.isEmpty ? 'Não informado' : _client.text}
Empresa: ${_company.text.isEmpty ? 'Não informado' : _company.text}
${_items.map((item) => '- ${item.product.name}: ${item.detail} | ${kz(item.total)}').join('\n')}

TOTAL: ${kz(_total)}
Observações: ${_notes.text}''';

  Future<void> _whatsapp() async {
    final uri = Uri.parse(
      'https://wa.me/244922462606?text=${Uri.encodeComponent(_quoteText())}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<Uint8List> _makePdf() async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Container(
            color: PdfColor.fromHex('#D8006C'),
            padding: const pw.EdgeInsets.all(20),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'MC GLOBAL',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'PUBLICIDADES',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Luanda - Angola  |  922 462 606  |  mcglobal.publicidade@gmail.com',
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Cliente: ${_client.text.isEmpty ? 'Não informado' : _client.text}',
          ),
          pw.Text(
            'Empresa: ${_company.text.isEmpty ? 'Não informado' : _company.text}',
          ),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: ['Produto', 'Detalhes', 'Subtotal'],
            data: _items
                .map((item) => [item.product.name, item.detail, kz(item.total)])
                .toList(),
          ),
          pw.SizedBox(height: 18),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'TOTAL: ${kz(_total)}',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Observações: ${_notes.text}'),
        ],
      ),
    );
    return document.save();
  }

  Future<void> _pdf() async => Printing.sharePdf(
    bytes: await _makePdf(),
    filename: 'orcamento_mc_global.pdf',
  );

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();
    _syncSelection(catalog);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final content = wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _calculator(catalog)),
                      const SizedBox(width: 22),
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            _cart(),
                            const SizedBox(height: 18),
                            _clientPanel(),
                            const SizedBox(height: 18),
                            _actions(),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _calculator(catalog),
                      const SizedBox(height: 18),
                      _cart(),
                      const SizedBox(height: 18),
                      _clientPanel(),
                      const SizedBox(height: 18),
                      _actions(),
                    ],
                  );
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _header(wide)),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    wide ? 42 : 18,
                    22,
                    wide ? 42 : 18,
                    42,
                  ),
                  sliver: SliverToBoxAdapter(child: content),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _header(bool wide) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: wide ? 42 : 18, vertical: 22),
      decoration: const BoxDecoration(color: Color(0xFF19151A)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _yellow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'MC',
                style: TextStyle(
                  color: _red,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    children: [
                      TextSpan(
                        text: 'MC GLOBAL ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'PUBLICIDADES',
                        style: TextStyle(color: _yellow),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Transformamos sua marca em destaque!',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (wide) ...[
            _badge('QUALIDADE'),
            _badge('RAPIDEZ'),
            _badge('PREÇO JUSTO'),
          ],
        ],
      ),
    );
  }

  Widget _badge(String text) => Padding(
    padding: const EdgeInsets.only(left: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  Widget _actions() => Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: _items.isEmpty ? null : _pdf,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Descarregar PDF'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
          ),
          onPressed: _items.isEmpty ? null : _whatsapp,
          icon: const Icon(Icons.chat_outlined),
          label: const Text('Enviar WhatsApp'),
        ),
      ),
    ],
  );
}

class ProductSettingsPage extends StatelessWidget {
  const ProductSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<ProductCatalog>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar produtos'),
        backgroundColor: _pink,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final category in catalog.categories) ...[
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showCreateProductDialog(
                              context,
                              catalog,
                              category.name,
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar produto'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final product in category.products) ...[
                        _ProductEditorTile(product: product),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateProductDialog(
    BuildContext context,
    ProductCatalog catalog,
    String currentCategory,
  ) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController(text: '0');
    final formulaController = TextEditingController(text: 'preço × quantidade');
    String categoryName = currentCategory;
    String type = 'qtd';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Novo produto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: categoryName,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: catalog.categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.name,
                          child: Text(category.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      categoryName = value;
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do produto',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Preço'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: formulaController,
                  decoration: const InputDecoration(labelText: 'Fórmula'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de cálculo',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'qtd', child: Text('Quantidade')),
                    DropdownMenuItem(value: 'm2', child: Text('Por m²')),
                    DropdownMenuItem(
                      value: 'letra_cm',
                      child: Text('Por letra/cm'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      type = value;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final price =
                    double.tryParse(
                      priceController.text.replaceAll(',', '.'),
                    ) ??
                    0;
                await catalog.addProduct(
                  categoryName: categoryName,
                  name: nameController.text.trim().isEmpty
                      ? 'Novo produto'
                      : nameController.text.trim(),
                  price: price,
                  formula: formulaController.text.trim().isEmpty
                      ? 'preço × quantidade'
                      : formulaController.text.trim(),
                  type: type,
                );
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }
}

class _ProductEditorTile extends StatefulWidget {
  const _ProductEditorTile({required this.product});

  final Product product;

  @override
  State<_ProductEditorTile> createState() => _ProductEditorTileState();
}

class _ProductEditorTileState extends State<_ProductEditorTile> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _formulaController;
  late String _type;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _formulaController = TextEditingController(text: widget.product.formula);
    _type = widget.product.type;
  }

  @override
  void didUpdateWidget(covariant _ProductEditorTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id) {
      _nameController.text = widget.product.name;
      _priceController.text = widget.product.price.toString();
      _formulaController.text = widget.product.formula;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _formulaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<ProductCatalog>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name.isEmpty ? 'Novo produto' : widget.product.name,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome do produto'),
            onChanged: (value) =>
                catalog.updateProduct(widget.product, name: value),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Preço'),
            onChanged: (value) {
              final parsed = double.tryParse(value.replaceAll(',', '.'));
              if (parsed != null) {
                catalog.updateProduct(widget.product, price: parsed);
              }
            },
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _formulaController,
            decoration: const InputDecoration(labelText: 'Fórmula'),
            onChanged: (value) =>
                catalog.updateProduct(widget.product, formula: value),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Tipo de cálculo'),
            items: const [
              DropdownMenuItem(value: 'qtd', child: Text('Quantidade')),
              DropdownMenuItem(value: 'm2', child: Text('Por m²')),
              DropdownMenuItem(value: 'letra_cm', child: Text('Por letra/cm')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _type = value);
                catalog.updateProduct(widget.product, type: value);
              }
            },
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () async {
              await catalog.removeProduct(product: widget.product);
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remover produto'),
          ),
        ],
      ),
    );
  }
}
