import 'package:intl/intl.dart';

class IncomeForm {
  final String amount;
  final String category;
  final String type;
  final String paymentType;
  final String date;
  final String completeDate;
  final String uid;
  final String? documentId;

  IncomeForm({
    required this.amount,
    required this.category,
    required this.type,
    required this.paymentType,
    required String? date,
    required this.completeDate,
    required this.uid,
    this.documentId,
  }) : date = date ?? DateFormat('MMMM yyyy').format(DateTime.now());

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'type': type,
      'paymentType': paymentType,
      'completeDate': completeDate,
      'date': date,
      'uid': uid,
    };
  }

  IncomeForm copyWith({
    String? amount,
    String? category,
    String? type,
    String? paymentType,
    String? completeDate,
    String? date,
    String? uid,
    String? documentId,
  }) {
    return IncomeForm(
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      paymentType: paymentType ?? this.paymentType,
      date: date ?? this.date,
      completeDate: completeDate ?? this.completeDate,
      uid: uid ?? this.uid,
      documentId: documentId ?? this.documentId,
    );
  }

  factory IncomeForm.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return IncomeForm(
      amount: map['amount'] ?? '',
      category: map['category'] ?? '',
      type: map['type'] ?? '',
      paymentType: map['paymentType'] ?? '',
      date: map['date'] ?? '',
      completeDate: map['completeDate'] ?? '',
      uid: map['uid'] ?? '',
      documentId: documentId,
    );
  }
}
