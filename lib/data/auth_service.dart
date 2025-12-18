import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -----------------------------------------
  // 1. ĐĂNG KÝ (SIGN UP)
  // -----------------------------------------
  Future<String?> signUp({required String email, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sau khi đăng ký thành công, lưu thông tin phân quyền vào Firestore
      if (credential.user != null) {
        await _db.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'role': 'user', // Mặc định là user
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null; // Trả về null nếu thành công
    } on FirebaseAuthException catch (e) {
      // Trả về thông báo lỗi cụ thể
      return e.code;
    } catch (e) {
      return e.toString();
    }
  }

  // -----------------------------------------
  // 2. ĐĂNG NHẬP (SIGN IN)
  // -----------------------------------------
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  // -----------------------------------------
  // 3. QUÊN MẬT KHẨU (PASSWORD RESET)
  // -----------------------------------------
  Future<String?> resetPassword({required String email}) async {
    try {
      // Phương thức quan trọng nhất: gửi email đặt lại mật khẩu
      await _auth.sendPasswordResetEmail(email: email);
      return 'success'; // Trả về 'success' nếu không có lỗi
    } on FirebaseAuthException catch (e) {
      // Trả về mã lỗi Firebase nếu có lỗi (ví dụ: user-not-found)
      return e.code;
    } catch (e) {
      return e.toString();
    }
  }

  // -----------------------------------------
  // 4. ĐĂNG XUẤT (SIGN OUT)
  // -----------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // -----------------------------------------
  // 5. ĐĂNG NHẬP BẰNG SỐ ĐIỆN THOẠI (PHONE AUTH)
  // -----------------------------------------
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<String?> signInWithCredential(AuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        // Kiểm tra xem user đã tồn tại trong Firestore chưa, nếu chưa thì tạo mới
        final userDoc = await _db.collection('users').doc(userCredential.user!.uid).get();
        if (!userDoc.exists) {
           await _db.collection('users').doc(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'phoneNumber': userCredential.user!.phoneNumber,
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      return e.toString();
    }
  }
}
