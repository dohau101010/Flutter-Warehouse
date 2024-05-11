import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

//Giao diện lịch sử giao dịch
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirebaseStringDisplayScreen(),
    );
  }
}

class FirebaseStringDisplayScreen extends StatefulWidget {
  @override
  _FirebaseStringDisplayScreenState createState() =>
      _FirebaseStringDisplayScreenState();
}

class _FirebaseStringDisplayScreenState
    extends State<FirebaseStringDisplayScreen> {
  // Danh sách để lưu trữ mỗi bản ghi thông tin
  List<Map<String, String>> records = [];

  @override
  void initState() {
    super.initState();
    final DatabaseReference ref = FirebaseDatabase.instance.ref('Lịch sử giao dịch');

    //Lắng nghe sự thay đổi thông số event
    ref.onValue.listen((DatabaseEvent event) {
      //Tạo 1 danh sách trống chứa dữ liệu
      final List<Map<String, String>> newRecords = [];

      //Kiêmr tra dữ liệu có phải là 1 map k
      if (event.snapshot.value is Map) {
        final Map<dynamic, dynamic> transactions = event.snapshot.value as Map<dynamic, dynamic>;

        transactions.forEach((key, value) {
          //duyệt qua từng phần tử trong lịch sử giao dịch
          if (value is Map) {
            final Map<dynamic, dynamic> transaction = value;
            //Lấy các thông số tại mỗi nút
            final String time = transaction['Thời gian']?.toString() ?? 'Unknown time';
            final String productName = transaction['Tên sản phẩm']?.toString() ?? 'Unknown product';
            final String quantity = transaction['Số lượng']?.toString() ?? 'Unknown quantity';

            //Thêm vào danh sách mới
            newRecords.add({
              'time': time,
              'productName': productName,
              'quantity': quantity,
            });
          }
        });
       //Cập nhật laij danh sách mới
        setState(() {
          // If you want the newest records at the top, use `reversed`
          records = newRecords.reversed.toList();
        });
      } else {
        // Handle the case where snapshot value is not a Map
        // Possibly log this situation or handle it as needed
        print('Data is not in expected format: ${event.snapshot.value}');
      }
    });
  }

//Xây dựng giao diện
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử xuất nhập kho'),
      ),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          // Bọc Row bên trong Container và thiết lập viền
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            // Tạo khoảng cách giữa các container
            padding: EdgeInsets.all(10),
            // Padding cho nội dung bên trong container
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black), // Màu viền
              borderRadius: BorderRadius.circular(5), // Bán kính viền bo tròn
            ),
            child: Row(
              //in ra các thông tin thời gian, tên sản phẩm và số lượng
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '${record['time']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    '${record['productName']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${record['quantity']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}