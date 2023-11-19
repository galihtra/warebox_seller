import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id; // Tambahkan properti ID
  final String userUid;
  final String reservationId;
  final double warehousePrice;
  final String paymentMethod;
  final String status;
  String? paymentReceiptImageUrl; // Buat properti tidak final

  Payment({
    required this.id,
    required this.userUid,
    required this.reservationId,
    required this.warehousePrice,
    required this.paymentMethod,
    required this.status,
    this.paymentReceiptImageUrl,
  });

  // Tambahkan konstruktor dari dokumen snapshot
  factory Payment.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Payment(
      id: snapshot.id, // Ambil ID dari snapshot
      userUid: data['userUid'],
      reservationId: data['reservationId'],
      warehousePrice: data['warehousePrice'],
      paymentMethod: data['paymentMethod'],
      status: data['status'],
      paymentReceiptImageUrl: data['paymentReceiptImageUrl'],
    );
  }
}
