import 'package:flutter/material.dart';
import 'anasayfa.dart';
import 'bootcamp.dart';
import 'hackatlon.dart';
import 'urunler.dart';
import 'ayarlar.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cook&Book',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const AnasayfaPage(),
        '/bootcamp': (_) => const BootcampPage(),
        '/hackatlon': (_) => const HackatlonPage(),
        '/urunler': (_) {
          final cart = ValueNotifier<List<Map<String, dynamic>>>([]);
          void add(Map<String, dynamic> item) {
            final list = List<Map<String, dynamic>>.from(cart.value);
            final idx = list.indexWhere((c) => c['id'] == item['id']);
            if (idx >= 0) {
              list[idx] = Map<String, dynamic>.from(list[idx])
                ..['quantity'] = (list[idx]['quantity'] as int? ?? 1) + 1;
            } else {
              final newItem = Map<String, dynamic>.from(item)..['quantity'] = 1;
              list.add(newItem);
            }
            cart.value = list;
          }

          // benzer şekilde increase/decrease/remove implement edin
          return UrunlerPage(
            cartNotifier: cart,
            onAddToCart: add,
            onIncreaseQty: (_) {},
            onDecreaseQty: (_) {},
            onRemoveFromCart: (_) {},
          );
        },
        '/ayarlar': (_) => const AyarlarPage(),
      },
    );
  }
}