import 'package:flutter/material.dart';

class UrunlerPage extends StatefulWidget {
  final ValueNotifier<List<Map<String, dynamic>>> cartNotifier;
  final void Function(Map<String, dynamic>) onAddToCart;
  final void Function(Map<String, dynamic>) onIncreaseQty;
  final void Function(Map<String, dynamic>) onDecreaseQty;
  final void Function(Map<String, dynamic>) onRemoveFromCart;

  const UrunlerPage({
    super.key,
    required this.cartNotifier,
    required this.onAddToCart,
    required this.onIncreaseQty,
    required this.onDecreaseQty,
    required this.onRemoveFromCart,
  });

  @override
  State<UrunlerPage> createState() => _UrunlerPageState();
}

class _UrunlerPageState extends State<UrunlerPage> {
  String _selectedCategory = 'Kitaplar';
  final List<String> categories = ['Kitaplar', 'Eğitim Kitapları'];

  final List<Map<String, dynamic>> products = [
    {
      'id': 1,
      'title': 'Clean Code',
      'price': 100.00,
      'category': 'Kitaplar',
      'image': 'assets/images/kitapkategorisi/Clean_Code.jpg',
    },
    {
      'id': 2,
      'title': 'Flutter ile Başlangıç',
      'price': 79.90,
      'category': 'Eğitim Kitapları',
      'image': 'assets/images/kitapkargorisi/flutter.jpg',
    },
    {
      'id': 3,
      'title': 'Design Patterns',
      'price': 99.90,
      'category': 'Kitaplar',
      'image': 'assets/images/kitapkargorisi/Design.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: widget.cartNotifier,
      builder: (context, cart, _) {
        final filtered = products
            .where((p) =>
                _selectedCategory == 'Kitaplar' ? true : p['category'] == _selectedCategory)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ürünler'),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (ctx) {
                            return _UrunlerCartPage(
                              cart: cart,
                              onRemove: widget.onRemoveFromCart,
                              onIncrease: widget.onIncreaseQty,
                              onDecrease: widget.onDecreaseQty,
                            );
                          }),
                        );
                      },
                    ),
                    if (cart.isNotEmpty)
                      Positioned(
                        right: 6,
                        top: 8,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            cart
                                .fold<int>(
                                    0, (s, it) => s + (it['quantity'] as int? ?? 1))
                                .toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Kategori seçimi
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final selected = cat == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: selected,
                            onSelected: (_) => setState(() {
                              _selectedCategory = cat;
                            }),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Ürün ızgarası
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      childAspectRatio: 0.60,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Resim
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.vertical(top: Radius.circular(8)),
                                child: Image.asset(
                                  item['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) =>
                                      const Center(child: Icon(Icons.broken_image, size: 40)),
                                ),
                              ),
                            ),

                            // Bilgiler ve butonlar
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${(item['price'] as num).toStringAsFixed(2)} TL',
                                    style: const TextStyle(
                                        color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.shopping_cart),
                                          label: const Text('Sepete Ekle'),
                                          onPressed: () {
                                            widget.onAddToCart(item);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('${item['title']} sepete eklendi'),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        icon: const Icon(Icons.favorite_border),
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${item['title']} favorilere eklendi',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _UrunlerCartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final void Function(Map<String, dynamic>)? onRemove;
  final void Function(Map<String, dynamic>)? onIncrease;
  final void Function(Map<String, dynamic>)? onDecrease;

  const _UrunlerCartPage({
    required this.cart,
    this.onRemove,
    this.onIncrease,
    this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final total = cart.fold<double>(
      0,
      (sum, item) =>
          sum + (item['price'] as num).toDouble() * (item['quantity'] as int? ?? 1),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Sepet')),
      body: cart.isEmpty
          ? const Center(child: Text('Sepetiniz boş'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: cart.length,
              itemBuilder: (context, i) {
                final item = cart[i];
                return Card(
                  child: ListTile(
                    leading: SizedBox(
                      width: 56,
                      child: Image.asset(
                        item['image'],
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                      ),
                    ),
                    title: Text(item['title']),
                    subtitle: Text(
                        '${(item['price'] as num).toStringAsFixed(2)} TL x ${item['quantity'] ?? 1}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => onDecrease?.call(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => onIncrease?.call(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onRemove?.call(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Toplam: ${total.toStringAsFixed(2)} TL',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            ElevatedButton(
              onPressed: cart.isEmpty
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ödeme işlemi simülasyonu')),
                      );
                    },
              child: const Text('Satın Al'),
            ),
          ],
        ),
      ),
    );
  }
}