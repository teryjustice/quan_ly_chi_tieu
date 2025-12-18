import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  // Lấy API key từ .env
  final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  AIService();

  /// Kiểm tra xem API key đã được cấu hình hay chưa
  bool get isConfigured => _apiKey.isNotEmpty;

  /// Gửi câu hỏi tới Gemini và trả về chuỗi phản hồi (plain text)
  /// Sử dụng `GenerativeModel.generateContent` API từ SDK.
  Future<String?> askQuestion(String prompt, {String model = 'gemini-2.5-flash'}) async {
    if (_apiKey.isEmpty) return null;

    try {
      final gen = GenerativeModel(
        model: model,
        apiKey: _apiKey,
      );

      final contents = [Content.text(prompt)];

      final GenerateContentResponse response = await gen.generateContent(contents);

      // Thử trả về `response.text` nếu SDK cung cấp
      final String? mainText = response.text;
      if (mainText != null && mainText.isNotEmpty) return mainText;

      // Nếu không có `text`, lấy từ candidate đầu tiên (sử dụng property `text`).
      if (response.candidates.isNotEmpty) {
        return response.candidates.first.text;
      }

      return null;
    } catch (e) {
      return 'Lỗi khi gọi Gemini: $e';
    }
  }

  /// Hàm hỗ trợ phân tích giao dịch — trả về Map nếu Gemini trả về JSON
  Future<Map<String, dynamic>?> analyzeTransactionText(String text) async {
    final prompt = '''Phân tích câu sau và trích xuất thông tin giao dịch.\nTrả về CHỈ một JSON duy nhất, không kèm giải thích.\nCấu trúc JSON phải là:{\n  "title": "Tiêu đề giao dịch",\n  "amount": 0.0,\n  "isExpense": true,\n  "date": "Hôm nay"\n}\nCâu: "$text"''';

    final raw = await askQuestion(prompt);
    if (raw == null) return null;

    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) return null;
    final jsonStr = raw.substring(start, end + 1);

    try {
      final Map<String, dynamic> map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return map;
    } catch (e) {
      return null;
    }
  }
}