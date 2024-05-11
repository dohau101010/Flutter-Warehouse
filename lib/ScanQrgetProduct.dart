import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart'; // Để định dạng ngày giờ

//Giao diện nhập hàng, quét mã QR và nhập hàng từ bàn phím
//khi bạn khai báo hàm main() với kiểu trả về là Future<void> thay vì void,
// điều này cho biết rằng hàm main() có thể thực hiện các hoạt động
// bất đồng bộ hoặc chờ đợi các tác vụ hoàn thành trước khi ứng dụng bắt đầu chạy.
//Nếu k saif future thì Điều này có thể dẫn đến lỗi hoặc vấn đề khi ứng dụng yêu cầu
// sử dụng các tính năng của Firebase trước khi chúng được khởi tạo hoàn toàn.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
//Giao diện chính khi ở màn hình quét mã QR
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRScanScreen(),
    );
  }
}

class QRScanScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  //cho phép bạn thực hiện một số thao tác như thao tác truy cập
  // hoặc điều khiển widget từ bất kỳ đâu trong ứng dụng
  final qrKey = GlobalKey(debugLabel: 'QR');
  //nó sẽ được sử dụng để quản lý và tương tác với một đối tượng
  // QRViewController, điều khiển quét mã QR
  QRViewController? controller;
  //Biến này có thể được sử dụng để lưu trữ mã sản phẩm hoặc mã QR được quét từ người dùng.
  String? productCode;
  //nhận và xử lý dữ liệu mà người dùng nhập vào trường nhập liệu về số lượng sản phẩm.
  TextEditingController quantityController = TextEditingController();

  @override
  // kiểm tra xem ứng dụng đang chạy trên nền tảng Android hay không.
  // Nếu điều kiện là đúng (Platform.isAndroid trả về true),
  // nó sẽ tạm dừng hoạt động của máy quét mã QR thông qua
  // biến controller bằng cách gọi phương thức pauseCamera()
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
  }
//Xây dựng giao diện quét mã
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét Mã QR'),
      ),
      body: Column(
        children: <Widget>[
          //Khung chứa camera để quét QR
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          //Xử lý hiển thị thông tin được quét
          Expanded(
            flex: 1,
            child: productCode != null
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mã hàng: ${parseProductCode(productCode!)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'Tên hàng: ${parseProductName(productCode!)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  //Nhập số lượng vào trường này
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nhập số lượng',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    onSubmitted: (value) {
                      final int? quantity = int.tryParse(value);
                      if (quantity != null) {
                        //Cập nhật lên firebase
                        updateProductQuantity(parseProductName(productCode!), quantity);
                      }
                    },
                  ),
                ],
              ),
            )
            //Thông báo hãy quét mã
                : const Center(child: Text('Vui lòng quét mã QR',
                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),)),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        productCode = scanData.code;
      });
      controller.pauseCamera(); // Tạm dừng camera sau khi quét thành công
    });
  }

   //Tách mã sản phẩm ra khỏi chuỗi
  String parseProductCode(String scannedData) {
    // Phần sau ký tự '-' là mã sản phẩm
    List<String> parts = scannedData.split('-');
    return parts.length > 1 ? parts[1] : 'Unknown Code';
  }
//Tách tên hàng ra khỏi chuỗi
  String parseProductName(String scannedData) {
    // Phần trước ký tự '-' là tên sản phẩm
    List<String> parts = scannedData.split('-');
    return parts.isNotEmpty ? parts[0] : 'Unknown Product';
  }

//Hàm cập nhật số lượng lên firebase, sử dụng push để k bị ghi đè
  //mà sẽ tạo 1 lịch sử giao dịch mới
  void updateProductQuantity(String productCode, int quantity) {
    FirebaseDatabase.instance.ref(productCode).set({'Số lượng': quantity});
    final String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    // Lưu chuỗi vào Firebase dưới nút "Lịch sử giao dịch"
    DatabaseReference ref = FirebaseDatabase.instance.ref('Lịch sử giao dịch');
    ref.push().set({
      'Thời gian': currentTime,
      'Tên sản phẩm': productCode,
      'Số lượng' : quantity.toString(),
    });
    //Thông báo cập nhật thành công tại thời gian
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$currentTime CẬP NHẬT ĐƠN HÀNG THÀNH CÔNG!'),
        duration: const Duration(seconds: 1),
      ),
    );
    //Chờ 1 giây sẽ trở về màn hình ban đầu
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    quantityController.dispose();
    super.dispose();
  }
}
