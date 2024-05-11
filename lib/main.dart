import 'package:flutter/material.dart';
import 'package:warehousemanager/YourStorageScreen.dart';
import 'package:warehousemanager/ScanQrgetProduct.dart';
import 'package:warehousemanager/PutProductScreen.dart';
import 'package:warehousemanager/YourHistoryScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Khởi tạo Binding (các file plugin)
  await Firebase.initializeApp(); //Khởi tạo dịch vụ Firebase
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
//Giao diện chính
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // Tạo thêm không gian cho AppBar
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 28), // Thêm padding trên tiêu đề
            child: Text(
              'WAREHOUSE',
              style: TextStyle(
                fontSize: 37,
                fontWeight: FontWeight.bold, // Font chữ đậm
                color: Colors.blue, // Màu xanh đậm
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(2.0, 2.0), // Vị trí bóng đổ
                    blurRadius: 3.0, // Độ mờ của bóng đổ
                    color: Color.fromARGB(255, 0, 0, 0), // Màu bóng đổ
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true, // Căn giữa tiêu đề
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Một hàng chứa 2 ảnh và tên
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cat character and name

                Expanded(
                  child: Column(
                    children: [
                      AspectRatio(
                          aspectRatio: 2, // Keep the image square
                          child: Image.asset('assets/cat_character.jpg'), // Replace with the

                      ),
                      Text(
                        'TRÚC MAI',
                        style: TextStyle(
                          fontSize: 20, // Adjust the size accordingly
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rabbit character and name
                Expanded(
                  child: Column(
                    children: [
                      AspectRatio(
                          aspectRatio: 2,
                          child: Image.asset('assets/rabbit_character.png'), // Replace with
                      ),
                      Text(
                        'VĂN NGUYÊN',
                        style: TextStyle(
                          fontSize: 20, // Adjust the size accordingly
                          fontWeight: FontWeight.bold,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 50),
            //Các nút nhấn, khi nhấn điều hướng sang màn hình mới
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRScanScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA3C9AA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                elevation: 10, // Đặt độ cao để tạo đổ bóng
              ),
              child: Text(
                'Nhập sản phẩm',
                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScanScreenPut()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8CB9BD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                elevation: 10, // Đặt độ cao để tạo đổ bóng
              ),
              child: Text(
                ' Xuất sản phẩm ',
                style: TextStyle(fontSize: 24,color: Colors.black),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => YourStorageScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA3C9AA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                elevation: 10, // Đặt độ cao để tạo đổ bóng
              ),
              child: Text(
                  '   Kho của bạn   ',

                style: TextStyle(fontSize: 24,color: Colors.black),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FirebaseStringDisplayScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8CB9BD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                elevation: 10, // Đặt độ cao để tạo đổ bóng
              ),
              child: Text(
                  '       Lịch sử       ',

                style: TextStyle(fontSize: 24, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
