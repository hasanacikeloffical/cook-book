import 'package:flutter/material.dart';
import 'urunler.dart';
import 'ayarlar.dart';
import 'bootcamp.dart';
import 'hackatlon.dart';

class AnasayfaPage extends StatefulWidget {
  const AnasayfaPage({super.key});

  @override
  State<AnasayfaPage> createState() => _AnasayfaPageState();
}

class _AnasayfaPageState extends State<AnasayfaPage> {
  int _currentIndex = 0;

  final ValueNotifier<List<Map<String, dynamic>>> _cart =
      ValueNotifier<List<Map<String, dynamic>>>([]);

  void _addToCart(Map<String, dynamic> item) {
    setState(() {});
    final list = List<Map<String, dynamic>>.from(_cart.value);
    final idx = list.indexWhere((c) => c['id'] == item['id']);
    if (idx >= 0) {
      list[idx] = Map<String, dynamic>.from(list[idx])
        ..['quantity'] = (list[idx]['quantity'] as int? ?? 1) + 1;
    } else {
      final newItem = Map<String, dynamic>.from(item);
      newItem['quantity'] = 1;
      list.add(newItem);
    }
    _cart.value = list;
  }

  void _increaseQty(Map<String, dynamic> item) {
    setState(() {});
    final list = List<Map<String, dynamic>>.from(_cart.value);
    final idx = list.indexWhere((c) => c['id'] == item['id']);
    if (idx >= 0) {
      list[idx] = Map<String, dynamic>.from(list[idx])
        ..['quantity'] = (list[idx]['quantity'] as int? ?? 1) + 1;
      _cart.value = list;
    }
  }

  void _decreaseQty(Map<String, dynamic> item) {
    setState(() {});
    final list = List<Map<String, dynamic>>.from(_cart.value);
    final idx = list.indexWhere((c) => c['id'] == item['id']);
    if (idx >= 0) {
      final q = (list[idx]['quantity'] as int? ?? 1) - 1;
      if (q <= 0) {
        list.removeAt(idx);
      } else {
        list[idx] = Map<String, dynamic>.from(list[idx])..['quantity'] = q;
      }
      _cart.value = list;
    }
  }

  void _removeFromCart(Map<String, dynamic> item) {
    setState(() {});
    final list = List<Map<String, dynamic>>.from(_cart.value)
      ..removeWhere((c) => c['id'] == item['id']);
    _cart.value = list;
  }

  List<Widget> get _pages => [
        UrunlerPage(
          cartNotifier: _cart,
          onAddToCart: _addToCart,
          onIncreaseQty: _increaseQty,
          onDecreaseQty: _decreaseQty,
          onRemoveFromCart: _removeFromCart,
        ),
        BootcampPage(),
        HackatlonPage(),
        AyarlarPage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Ürünler'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Bootcamp'),
          BottomNavigationBarItem(icon: Icon(Icons.code), label: 'Hackatlon'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final void Function(Map<String, dynamic>) onRemove;

  const CartPage({super.key, required this.cart, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final total = cart.fold<double>(
        0, (sum, item) => sum + (item['price'] as num).toDouble() * (item['quantity'] as int));
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
                        '${(item['price'] as num).toStringAsFixed(2)} TL x ${item['quantity']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => onRemove(item),
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
            Text('Toplam: ${total.toStringAsFixed(2)} TL',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ElevatedButton(
              onPressed: cart.isEmpty
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ödeme işlemi simülasyonu')),
                      );
                    },
              child: const Text('Satın Al'),
            )
          ],
        ),
      ),
    );
  }
}