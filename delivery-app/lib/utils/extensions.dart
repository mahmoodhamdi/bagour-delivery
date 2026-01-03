import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(r'^01[0125][0-9]{8}$').hasMatch(this);
  }

  bool get isValidPassword {
    return length >= 8;
  }

  bool get isValidNationalId {
    return RegExp(r'^[0-9]{14}$').hasMatch(this);
  }

  String get obscurePhone {
    if (length < 8) return this;
    return '${substring(0, 3)}****${substring(length - 4)}';
  }

  String get obscureEmail {
    final parts = split('@');
    if (parts.length != 2) return this;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return this;
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }
}

extension NumExtensions on num {
  String get toCurrency {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }

  String get toDecimalCurrency {
    final formatter = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 2,
    );
    return formatter.format(this);
  }

  String get toCompact {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  String get toDistance {
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)} كم';
    }
    return '${toStringAsFixed(0)} م';
  }

  String get toDuration {
    final minutes = (this / 60).floor();
    if (minutes < 60) {
      return '$minutes دقيقة';
    }
    final hours = (minutes / 60).floor();
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours ساعة';
    }
    return '$hours ساعة و $remainingMinutes دقيقة';
  }
}

extension DateTimeExtensions on DateTime {
  String get toDateString {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  String get toTimeString {
    return DateFormat('HH:mm').format(this);
  }

  String get toDateTimeString {
    return DateFormat('yyyy-MM-dd HH:mm').format(this);
  }

  String get toArabicDate {
    return DateFormat('d MMMM yyyy', 'ar').format(this);
  }

  String get toArabicDateTime {
    return DateFormat('d MMMM yyyy - h:mm a', 'ar').format(this);
  }

  String get toArabicTime {
    return DateFormat('h:mm a', 'ar').format(this);
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} سنة';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} شهر';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} أسبوع';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showLoadingDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }
}

extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  List<T> insertBetween(T separator) {
    if (length <= 1) return this;
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}

extension OrderStatusExtensions on String {
  String get toArabicStatus {
    switch (toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'preparing':
        return 'جاري التحضير';
      case 'ready':
        return 'جاهز للاستلام';
      case 'picked_up':
        return 'تم الاستلام';
      case 'on_the_way':
        return 'في الطريق';
      case 'delivered':
        return 'تم التوصيل';
      case 'cancelled':
        return 'ملغي';
      default:
        return this;
    }
  }

  Color get statusColor {
    switch (toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'ready':
        return Colors.green;
      case 'picked_up':
        return Colors.teal;
      case 'on_the_way':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
