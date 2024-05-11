import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: YourStorageScreenT(),
    );
  }
}

class YourStorageScreenT extends StatelessWidget {
  final List<Product> products = [
    Product(name: "Mặt nạ", itemCode: "TT01", icon: Icons.create, color: Colors.black, backgroundColor: Colors.pink[100]!),
    Product(name: "Son môi", itemCode: "TT02", icon: Icons.straighten, color: Colors.black, backgroundColor: Colors.lightBlue[100]!),
    Product(name: "Tiểu thuyết", itemCode: "TT03", icon: Icons.edit, color: Colors.black, backgroundColor: Colors.lightGreen[100]!),
    Product(name: "Giáo trình", itemCode: "TT04", icon: Icons.book, color: Colors.black, backgroundColor: Colors.amber[100]!),
    Product(name: "Chảo chống dính", itemCode: "TT05", icon: Icons.computer, color: Colors.black, backgroundColor: Colors.purple[100]!),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách sản phẩm'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (BuildContext context, int index) {
          return ProductListItem(product: products[index]);
        },
      ),
    );
  }
}

class Product {
  String name;
  String itemCode;
  IconData icon;
  Color color;
  Color backgroundColor;

  Product({
    required this.name,
    required this.itemCode,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  Stream<int> get quantityStream => getQuantityStream(name);
}

Stream<int> getQuantityStream(String productName) {
  DatabaseReference quantityRef = FirebaseDatabase.instance.ref('$productName/Số lượng');
  return quantityRef.onValue.map((event) {
    final int? quantity = event.snapshot.value as int?;
    return quantity ?? 0;
  });
}

class ProductListItem extends StatelessWidget {
  final Product product;

  ProductListItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
       color: Color(0xFFF5E8DD),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        leading: Icon(product.icon, color: product.color),
        title: Text(
          product.name,
          style: TextStyle(
            color: product.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Mã hàng: ${product.itemCode}',
          style: TextStyle(
            color: product.color,
            fontSize: 18,
          ),
        ),
        trailing: StreamBuilder<int>(
          stream: product.quantityStream,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final quantity = snapshot.data ?? 0;
            return Text(
              'Số lượng: ${quantity.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: product.color,
                fontSize: 16,
              ),
            );
          },
        ),
      ),
    );
  }
}
