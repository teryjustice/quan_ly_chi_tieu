import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import 'package:quan_ly_chi_tieu/screens/add_transaction_screen.dart';
import 'package:quan_ly_chi_tieu/screens/ai_chat_screen.dart';
import 'category_screen.dart';
import 'user_info_screen.dart';
import 'statistics_screen.dart';
import 'transaction_history_screen.dart';
import 'comparison_detail_screen.dart';
import 'transfer_screen.dart';
import 'qr_scanner_screen.dart';
import 'inbox_screen.dart';
import 'budget_screen.dart';
import 'savings_screen.dart';
import 'payment_list_screen.dart'; // Import payment list screen

class ServiceItem {
  final IconData icon;
  final String Function(BuildContext) titleBuilder; // Builder function for localized title
  final VoidCallback onTap;
  final Color? color;

  ServiceItem({
    required this.icon,
    required this.titleBuilder,
    required this.onTap,
    this.color,
  });
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0; 

  final List<Widget> _pages = [
    const _HomeContent(),
    const TransactionHistoryScreen(),
    const BudgetScreen(),
    const InboxScreen(),
    const UserInfoScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Để localization hoạt động ở đây, ta cần check locale
    // Nhưng NavigationBar labels thường là tĩnh. Để dynamic, ta cần build lại khi locale thay đổi.
    // Vì HomeScreen là StatefulWidget, setState sẽ rebuild, nhưng cần trigger khi locale thay đổi.
    // Tuy nhiên, nếu Locale thay đổi ở cấp App, toàn bộ widget tree rebuild.
    
    // Check if AppLocalizations is available
    final currentLocale = Localizations.localeOf(context);
    final isEnglish = currentLocale.languageCode == 'en';
    
    final homeLabel = isEnglish ? 'Home' : 'Trang chủ';
    final historyLabel = isEnglish ? 'History' : 'Lịch sử';
    final budgetLabel = isEnglish ? 'Budget' : 'Ngân sách';
    final inboxLabel = isEnglish ? 'Inbox' : 'Hộp thư';
    final profileLabel = isEnglish ? 'Profile' : 'Cá nhân';

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        indicatorColor: Theme.of(context).primaryColor.withAlpha(50),
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: const Icon(Icons.home),
            icon: const Icon(Icons.home_outlined),
            label: homeLabel,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.history),
            icon: const Icon(Icons.history_outlined),
            label: historyLabel,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.account_balance),
            icon: const Icon(Icons.account_balance_outlined),
            label: budgetLabel,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.notifications),
            icon: const Icon(Icons.notifications_outlined),
            label: inboxLabel,
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.person),
            icon: const Icon(Icons.person_outline),
            label: profileLabel,
          ),
        ],
      ),
      
      floatingActionButton: _selectedIndex == 0 
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionStreamProvider);
    final userRole = ref.watch(userRoleProvider);

    final List<ServiceItem> serviceItems = [
      ServiceItem(
        icon: Icons.qr_code_scanner,
        titleBuilder: (ctx) {
           final isEn = Localizations.localeOf(ctx).languageCode == 'en';
           return isEn ? 'Scan QR' : 'Quét Mã';
        },
        color: Colors.blue,
        onTap: () async {
          final qrCode = await Navigator.of(context).push<String>(
            MaterialPageRoute(builder: (context) => const QRScannerScreen()),
          );
          if (qrCode != null && qrCode.isNotEmpty && context.mounted) {
            _handleScannedQRCode(context, qrCode);
          }
        },
      ),
      ServiceItem(
        icon: Icons.send_to_mobile,
        titleBuilder: (ctx) {
           final isEn = Localizations.localeOf(ctx).languageCode == 'en';
           return isEn ? 'Transfer' : 'Chuyển Tiền';
        },
        color: Colors.purple,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TransferScreen()),
          );
        },
      ),
      ServiceItem(
        icon: Icons.savings,
        titleBuilder: (ctx) {
           final isEn = Localizations.localeOf(ctx).languageCode == 'en';
           return isEn ? 'Savings' : 'Gửi Tiết Kiệm';
        },
        color: Colors.pink,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SavingsScreen()),
          );
        },
      ),
      ServiceItem(
        icon: Icons.payment,
        titleBuilder: (ctx) {
           final isEn = Localizations.localeOf(ctx).languageCode == 'en';
           return isEn ? 'Payment' : 'Thanh Toán';
        },
        color: Colors.orange,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PaymentListScreen()),
          );
        },
      ),
      ServiceItem(
        icon: Icons.auto_graph,
        titleBuilder: (ctx) {
           final isEn = Localizations.localeOf(ctx).languageCode == 'en';
           return isEn ? 'Statistics' : 'Thống Kê';
        },
        color: Colors.green,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const StatisticsScreen()),
          );
        },
      ),
       ServiceItem(
        icon: Icons.compare_arrows,
        titleBuilder: (ctx) {
           final isEn = Localizations.localeOf(ctx).languageCode == 'en';
           return isEn ? 'Comparison' : 'So Sánh';
        },
        color: Colors.teal,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ComparisonDetailScreen()),
          );
        },
      ),
      ServiceItem(
        icon: Icons.chat_bubble_outline,
        titleBuilder: (ctx) => 'AI Chat',
        color: Colors.indigo,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AIChatScreen()),
          );
        },
      ),
       if (userRole.value == 'admin')
         ServiceItem(
          icon: Icons.admin_panel_settings_outlined,
          titleBuilder: (ctx) => 'Admin',
          color: Colors.grey[700],
          onTap: () {
            Navigator.of(context).push(
               MaterialPageRoute(builder: (context) => const CategoryScreen()),
            );
          },
        ),
      ServiceItem(
        icon: Icons.more_horiz,
        titleBuilder: (ctx) {
           final isEn = Localizations.localeOf(ctx).languageCode == 'en';
           return isEn ? 'More' : 'Xem thêm';
        },
        color: Colors.pink,
        onTap: () {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đang phát triển...')),
          );
        },
      ),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCustomHeader(context, ref, transactionsAsyncValue),
            const SizedBox(height: 10),
            _buildServiceGrid(context, serviceItems),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, WidgetRef ref, AsyncValue transactionsAsyncValue) {
    final authState = ref.watch(authStateChangesProvider);
    final user = authState.value;
    final currentLocale = Localizations.localeOf(context);
    final isEnglish = currentLocale.languageCode == 'en';

    final double totalBalance = transactionsAsyncValue.when(
      data: (transactions) {
        double income = 0;
        double expense = 0;
        for (var tx in transactions) {
          if (tx.isExpense) {
            expense += tx.amount;
          } else {
            income += tx.amount;
          }
        }
        return income - expense;
      },
      loading: () => 0.0,
      error: (_, __) => 0.0,
    );
    
    final formattedBalance = NumberFormat('#,##0 đ', 'en_US').format(totalBalance);
    
    final helloText = isEnglish ? 'Hello,' : 'Xin chào,';
    final balanceText = isEnglish ? 'Total Balance' : 'Tổng số dư';
    final userDisplayName = user?.displayName ?? (isEnglish ? 'Friend' : 'Bạn');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null ? Icon(Icons.person, color: Theme.of(context).primaryColor) : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helloText,
                        style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12),
                      ),
                      Text(
                        userDisplayName,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {
                       Navigator.of(context).push(MaterialPageRoute(builder: (context) => const InboxScreen()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                balanceText,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                formattedBalance,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              const SizedBox(height: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context, List<ServiceItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(30),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.72,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: item.onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (item.color ?? Theme.of(context).primaryColor).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.color ?? Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.titleBuilder(context), // Build title dynamically
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleScannedQRCode(BuildContext context, String qrCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('QR Code'),
        content: Text(qrCode),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }
}
