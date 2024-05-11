import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart'; // Để định dạng ngày giờ

//Giao diện quét mã QR, sản phẩm trừ 1
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QRScanScreenPut(),
    );
  }
}

class QRScanScreenPut extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _QRScanScreenPutState();
}

class _QRScanScreenPutState extends State<QRScanScreenPut> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scannedData;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
  }

  //Xử lý giao diện
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xuất Sản Phẩm'),
      ),
      body: Column(
        children: <Widget>[
          //Khung chứa camera
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated, //quét mã và lấy dữ liệu
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: scannedData != null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.start, //căn từ bên trái
                children: [
                  Text(
                    'Tên hàng: ${parseProductName(scannedData!)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'Mã hàng: ${parseProductCode(scannedData!)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              )
                  : const Text('Vui lòng quét mã QR',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      final code = scanData.code;
      if (code != null) {
        setState(() {
          scannedData = code;
        });
        controller.pauseCamera(); // Tạm dừng camera sau khi quét thành công
        await updateProductQuantity(parseProductName(scannedData!));
      }
    });
  }
//Cập nhật số lượng sản phẩm gửi lại firebase
  Future<void> updateProductQuantity(String productCode) async {
    DatabaseReference quantityRef = FirebaseDatabase.instance.ref('$productCode/Số lượng');

    DataSnapshot snapshot = (await quantityRef.once()).snapshot;
    final int? currentQuantity = snapshot.value as int?;

      if (currentQuantity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi khi đọc số lượng sản phẩm!')),
        );
        return;
      }

      if (currentQuantity == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('XIN LỖI! ĐƠN HÀNG ĐÃ HẾT!')),
        );
      } else {
        int newQuantity = currentQuantity - 1;
        //Giam sản phẩm đi 1 và cập nhật
        await FirebaseDatabase.instance.ref(productCode).set({'Số lượng': newQuantity});

        final String formattedTime = DateFormat('HH:mm:ss').format(DateTime.now());
        //Đẩy dữ liệu vào lịch sử giao dịch
        DatabaseReference ref = FirebaseDatabase.instance.ref('Lịch sử giao dịch');
        ref.push().set({
          'Thời gian': formattedTime,
          'Tên sản phẩm': productCode,
          'Số lượng' : "-1",
        });
//Thông báo xuất thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$formattedTime XUẤT THÀNH CÔNG ĐƠN HÀNG! Số lượng còn lại: $newQuantity')),
        );
      }
      //Chờ 1 giây quay về màn hình chính
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  String parseProductCode(String scannedData) {
    // Phần sau ký tự '-' là mã sản phẩm
    List<String> parts = scannedData.split('-');
    return parts.length > 1 ? parts[1] : 'Unknown Code';
  }

  String parseProductName(String scannedData) {
    // Phần trước ký tự '-' là tên sản phẩm
    List<String> parts = scannedData.split('-');
    return parts.isNotEmpty ? parts[0] : 'Unknown Product';
  }


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}