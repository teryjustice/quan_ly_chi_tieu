import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';

class UserInfoScreen extends ConsumerStatefulWidget {
  const UserInfoScreen({super.key});

  @override
  ConsumerState<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends ConsumerState<UserInfoScreen> {
  bool _uploading = false;

  Future<void> _showPickOptionsDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ Thư viện'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadFrom(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Chụp ảnh Camera'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickAndUploadFrom(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadFrom(ImageSource source) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    setState(() => _uploading = true);

    try {
      final file = File(picked.path);

      // Choose storage instance based on firebase options.bucket if present
      final app = Firebase.app();
      String? optionsBucket = app.options.storageBucket;
      FirebaseStorage storageInstance;
      String usedBucketDesc;

      if (optionsBucket != null && optionsBucket.isNotEmpty) {
        final bucketUrl = optionsBucket.startsWith('gs://') ? optionsBucket : 'gs://$optionsBucket';
        storageInstance = FirebaseStorage.instanceFor(bucket: bucketUrl);
        usedBucketDesc = bucketUrl;
      } else {
        storageInstance = FirebaseStorage.instance;
        usedBucketDesc = 'default';
      }

      // ignore: avoid_print
      print('[DEBUG] Using Firebase Storage bucket: $usedBucketDesc');

      final storageRef = storageInstance.ref().child('user_avatars/${user.uid}.jpg');
      // ignore: avoid_print
      print('[DEBUG] Uploading to path: ${storageRef.fullPath}');

      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      // ignore: avoid_print
      print('[DEBUG] UploadTask state: ${snapshot.state}; bytesTransferred=${snapshot.bytesTransferred}; total=${snapshot.totalBytes}');
      // ignore: avoid_print
      print('[DEBUG] Uploaded ref fullPath: ${snapshot.ref.fullPath}');
      // ignore: avoid_print
      print('[DEBUG] Uploaded metadata bucket: ${snapshot.metadata?.bucket}');

      // Try to get the download URL from the same storage instance
      final downloadUrl = await storageRef.getDownloadURL();
      // ignore: avoid_print
      print('[DEBUG] Download URL: $downloadUrl');

      // Update FirebaseAuth profile
      await user.updatePhotoURL(downloadUrl);

      // Also save to Firestore users collection
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoURL': downloadUrl,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật ảnh đại diện')));
      }
      setState(() => _uploading = false);
      // Force UI refresh
      await FirebaseAuth.instance.currentUser?.reload();
      setState(() {});
    } on FirebaseException catch (e) {
      setState(() => _uploading = false);
      final msg = 'Lỗi upload (${e.code}): ${e.message ?? e.toString()}';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
      // ignore: avoid_print
      print('[ERROR] FirebaseException during avatar upload: ${e.code} / ${e.message}');
    } catch (e, st) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi upload: $e')));
      }
      // ignore: avoid_print
      print('[ERROR] Exception during avatar upload: $e');
      // ignore: avoid_print
      print(st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userRoleAsyncValue = ref.watch(userRoleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Tin Tài Khoản'),
        backgroundColor: Colors.grey[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tài khoản đang đăng nhập',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // Avatar + Email
            Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null ? const Icon(Icons.person, size: 36, color: Colors.pink) : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _uploading ? null : _showPickOptionsDialog,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: _uploading ? const SizedBox(width:20, height:20, child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.camera_alt, size:18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ListTile(
                    title: Text('Email: ${user?.email ?? "Không xác định"}'),
                    subtitle: Text('UID: ${user != null && user.uid.length >= 10 ? user.uid.substring(0, 10) : (user?.uid ?? "N/A")}...'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              'Vai trò & Quyền hạn',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            userRoleAsyncValue.when(
              data: (role) => ListTile(
                leading: Icon(
                  role == 'admin' ? Icons.verified_user : Icons.person,
                  color: role == 'admin' ? Colors.red : Colors.blue,
                ),
                title: const Text('Vai trò hệ thống'),
                subtitle: Text(
                  role == 'admin' ? 'Quản trị viên (ADMIN)' : 'Người dùng (USER)',
                  style: TextStyle(fontWeight: FontWeight.bold, color: role == 'admin' ? Colors.red : Colors.black),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const ListTile(title: Text('Không thể tải vai trò.')),
            ),

            const SizedBox(height: 40),

            const Text(
              'Cài Đặt Ngôn Ngữ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(localeProvider.notifier).setLocale(const Locale('vi', ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã chuyển sang Tiếng Việt'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD82D8B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Tiếng Việt (VN)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(localeProvider.notifier).setLocale(const Locale('en', ''));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Switched to English'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('English (US)'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Chỉ cần gọi signOut, AuthChecker sẽ tự động điều hướng về màn hình đăng nhập
                  // Không gọi navigator.pop() ở đây vì UserInfoScreen nằm trong TabView, không phải màn hình được push vào stack
                  await ref.read(authServiceProvider).signOut();
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Đăng Xuất', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
