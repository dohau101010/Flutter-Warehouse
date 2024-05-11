import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
//Giao diện nhà kho
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: YourStorageScreen(),
    );
  }
}
//Danh sách các sản phẩm và bố trí
class YourStorageScreen extends StatelessWidget {
  final List<Product> products = [
    Product(name: "Bút bi", itemCode: "KATH1", icon: Icons.create, color: Colors.black, backgroundColor: Colors.pink[100]!),
    Product(name: "Thước kẻ", itemCode: "KATH2", icon: Icons.straighten, color: Colors.black, backgroundColor: Colors.lightBlue[100]!),
    Product(name: "Bút chì", itemCode: "KATH3", icon: Icons.edit, color: Colors.black, backgroundColor: Colors.lightGreen[100]!),
    Product(name: "Tập viết", itemCode: "KATH4", icon: Icons.book, color: Colors.black, backgroundColor: Colors.amber[100]!),
    Product(name: "Compa", itemCode: "KATH5", icon: Icons.computer, color: Colors.black, backgroundColor: Colors.purple[100]!),
    Product(name: "Tẩy", itemCode: "KATH6", icon: Icons.delete, color: Colors.black, backgroundColor: Colors.teal[100]!),
    Product(name: "Màu sáp", itemCode: "KATH7", icon: Icons.color_lens, color: Colors.black, backgroundColor: Colors.deepPurple[100]!),
    Product(name: "Đồng hồ", itemCode: "KATH8", icon: Icons.watch, color: Colors.black, backgroundColor: Colors.brown[100]!),
    Product(name: "Truyện tranh", itemCode: "KATH9", icon: Icons.art_track, color: Colors.black, backgroundColor: Colors.orange[100]!),
    Product(name: "Giấy A4", itemCode: "KATH10", icon: Icons.description, color: Colors.black, backgroundColor: Colors.grey[100]!),
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
//Class quản lý các thông tin sản phẩm
class Product {
  String name; //Tên hàng
  String itemCode; //Mã hàng
  IconData icon; //Icon
  Color color;
  Color backgroundColor;

  Product({ //Contructor
    required this.name,
    required this.itemCode,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  //Lấy dữ liệu từ Firebase thông qua tên hàng
  Stream<int> get quantityStream => getQuantityStream(name);
}

//Dựa trên đường dẫn tới thư mục có tên sản phẩm tương ứng để lấy về
//khi có sự thay đổi
Stream<int> getQuantityStream(String productName) {
  DatabaseReference quantityRef = FirebaseDatabase.instance.ref('$productName/Số lượng');
  return quantityRef.onValue.map((event) {
    final int? quantity = event.snapshot.value as int?;
    return quantity ?? 0;
  });
}

//Tạo lớp chứa thông tin sản phẩm đã lấy về (số lượng)
class ProductListItem extends StatelessWidget {
  final Product product;

  ProductListItem({required this.product});

  @override
  Widget build(BuildContext context) {
    //Giao diện hiển thị nhà kho
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: product.backgroundColor,
        borderRadius: BorderRadius.circular(10.0),
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
        //trailing: phần tử nămf bên phải (số lượng)
        trailing: StreamBuilder<int>(
          stream: product.quantityStream,
          //Nếu chưa kết nối được Firebase thì quay tròn
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            //Nếu có lỗi thì báo lỗi
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            //Lấy được thì gán cho biến quantity
            final quantity = snapshot.data ?? 0;
            //Sau đó hiển thị ra
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
