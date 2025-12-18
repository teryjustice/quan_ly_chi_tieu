import 'package:flutter/material.dart';

/// Localization helper to provide translations from .arb files
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('vi', ''));
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'appTitle': 'Money Wallet',
      'home': 'Home',
      'statistics': 'Statistics',
      'categories': 'Categories',
      'settings': 'Settings',
      'addTransaction': 'Add Transaction',
      'expense': 'Expense',
      'income': 'Income',
      'deposit': 'Deposit',
      'category': 'Category',
      'amount': 'Amount',
      'date': 'Date',
      'description': 'Description',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'update': 'Update',
      'logout': 'Logout',
      'login': 'Login',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'forgotPassword': 'Forgot Password?',
      'resetPassword': 'Reset Password',
      'name': 'Name',
      'phone': 'Phone',
      'address': 'Address',
      'profile': 'Profile',
      'recentTransactions': 'Recent Transactions',
      'totalIncome': 'Total Income',
      'totalExpense': 'Total Expense',
      'balance': 'Balance',
      'monthlyComparison': 'Monthly Comparison',
      'categoryStats': 'Category Statistics',
      'transactionHistory': 'Transaction History',
      'transfer': 'Transfer',
      'transferMoney': 'Transfer Money',
      'recipient': 'Recipient',
      'scanQR': 'Scan QR Code',
      'chat': 'Chat',
      'aiChat': 'AI Chat',
      'welcome': 'Welcome',
      'successMessage': 'Operation successful',
      'errorMessage': 'An error occurred',
      'loading': 'Loading...',
      'noData': 'No data available',
      'selectDate': 'Select Date',
      'selectCategory': 'Select Category',
      'allTransactions': 'All Transactions',
      'thisMonth': 'This Month',
      'lastMonth': 'Last Month',
      'yearly': 'Yearly',
      'daily': 'Daily',
      'monthly': 'Monthly',
      'weekly': 'Weekly',
    },
    'vi': {
      'appTitle': 'Ví Tiền',
      'home': 'Trang Chủ',
      'statistics': 'Thống Kê',
      'categories': 'Danh Mục',
      'settings': 'Cài Đặt',
      'addTransaction': 'Thêm Giao Dịch',
      'expense': 'Chi Tiêu',
      'income': 'Thu Nhập',
      'deposit': 'Nạp Tiền',
      'category': 'Danh Mục',
      'amount': 'Số Tiền',
      'date': 'Ngày',
      'description': 'Mô Tả',
      'save': 'Lưu',
      'cancel': 'Hủy',
      'delete': 'Xóa',
      'edit': 'Sửa',
      'add': 'Thêm',
      'update': 'Cập Nhật',
      'logout': 'Đăng Xuất',
      'login': 'Đăng Nhập',
      'signup': 'Đăng Ký',
      'email': 'Email',
      'password': 'Mật Khẩu',
      'confirmPassword': 'Xác Nhận Mật Khẩu',
      'forgotPassword': 'Quên Mật Khẩu?',
      'resetPassword': 'Đặt Lại Mật Khẩu',
      'name': 'Tên',
      'phone': 'Điện Thoại',
      'address': 'Địa Chỉ',
      'profile': 'Hồ Sơ',
      'recentTransactions': 'Giao Dịch Gần Đây',
      'totalIncome': 'Tổng Thu Nhập',
      'totalExpense': 'Tổng Chi Tiêu',
      'balance': 'Số Dư',
      'monthlyComparison': 'So Sánh Hàng Tháng',
      'categoryStats': 'Thống Kê Danh Mục',
      'transactionHistory': 'Lịch Sử Giao Dịch',
      'transfer': 'Chuyển Tiền',
      'transferMoney': 'Chuyển Tiền',
      'recipient': 'Người Nhận',
      'scanQR': 'Quét Mã QR',
      'chat': 'Trò Chuyện',
      'aiChat': 'AI Chat',
      'welcome': 'Chào Mừng',
      'successMessage': 'Thành Công',
      'errorMessage': 'Đã Xảy Ra Lỗi',
      'loading': 'Đang Tải...',
      'noData': 'Không Có Dữ Liệu',
      'selectDate': 'Chọn Ngày',
      'selectCategory': 'Chọn Danh Mục',
      'allTransactions': 'Tất Cả Giao Dịch',
      'thisMonth': 'Tháng Này',
      'lastMonth': 'Tháng Trước',
      'yearly': 'Hàng Năm',
      'daily': 'Hàng Ngày',
      'monthly': 'Hàng Tháng',
      'weekly': 'Hàng Tuần',
    },
  };

  String translate(String key) {
    return _translations[locale.languageCode]?[key] ?? key;
  }

  String get appTitle => translate('appTitle');
  String get home => translate('home');
  String get statistics => translate('statistics');
  String get categories => translate('categories');
  String get settings => translate('settings');
  String get addTransaction => translate('addTransaction');
  String get expense => translate('expense');
  String get income => translate('income');
  String get deposit => translate('deposit');
  String get category => translate('category');
  String get amount => translate('amount');
  String get date => translate('date');
  String get description => translate('description');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get update => translate('update');
  String get logout => translate('logout');
  String get login => translate('login');
  String get signup => translate('signup');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get forgotPassword => translate('forgotPassword');
  String get resetPassword => translate('resetPassword');
  String get name => translate('name');
  String get phone => translate('phone');
  String get address => translate('address');
  String get profile => translate('profile');
  String get recentTransactions => translate('recentTransactions');
  String get totalIncome => translate('totalIncome');
  String get totalExpense => translate('totalExpense');
  String get balance => translate('balance');
  String get monthlyComparison => translate('monthlyComparison');
  String get categoryStats => translate('categoryStats');
  String get transactionHistory => translate('transactionHistory');
  String get transfer => translate('transfer');
  String get transferMoney => translate('transferMoney');
  String get recipient => translate('recipient');
  String get scanQR => translate('scanQR');
  String get chat => translate('chat');
  String get aiChat => translate('aiChat');
  String get welcome => translate('welcome');
  String get successMessage => translate('successMessage');
  String get errorMessage => translate('errorMessage');
  String get loading => translate('loading');
  String get noData => translate('noData');
  String get selectDate => translate('selectDate');
  String get selectCategory => translate('selectCategory');
  String get allTransactions => translate('allTransactions');
  String get thisMonth => translate('thisMonth');
  String get lastMonth => translate('lastMonth');
  String get yearly => translate('yearly');
  String get daily => translate('daily');
  String get monthly => translate('monthly');
  String get weekly => translate('weekly');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
