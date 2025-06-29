import 'package:intl/intl.dart';

class TransactionForm {
  final String amount;
  final String category;
  final String type;
  final String paymentType;
  final String date;
  final String completeDate;
  final String uid;
  final String? documentId;

  TransactionForm({
    required this.amount,
    required this.category,
    required this.paymentType,
    required this.type,
    required this.date,
    required this.completeDate,
    required this.uid,
    this.documentId,
  });

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

  TransactionForm copyWith({
    String? amount,
    String? category,
    String? paymentType,
    String? date,
    String? type,
    String? completeDate,
    String? uid,
    String? documentId,
  }) {
    return TransactionForm(
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      completeDate: completeDate ?? this.completeDate,
      paymentType: paymentType ?? this.paymentType,
      date: date ?? this.date,
      uid: uid ?? this.uid,
      documentId: documentId ?? this.documentId,
    );
  }

  factory TransactionForm.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return TransactionForm(
      amount: map['amount'] ?? '',
      category: map['category'] ?? '',
      type: map['type'] ?? '',
      completeDate: map['completeDate'] ?? '',
      paymentType: map['paymentType'] ?? '',
      date: map['date'] ?? '',
      uid: map['uid'] ?? '',
      documentId: documentId,
    );
  }
}
