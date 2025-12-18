import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/transaction_provider.dart'; // Cho firestoreServiceProvider
import '../widgets/color_icon_picker.dart';

class CategoryAddScreen extends ConsumerStatefulWidget {
  // Tham số TÙY CHỌN: nếu có, đây là chế độ SỬA
  final CategoryModel? categoryToEdit;

  const CategoryAddScreen({super.key, this.categoryToEdit});

  @override
  ConsumerState<CategoryAddScreen> createState() => _CategoryAddScreenState();
}

class _CategoryAddScreenState extends ConsumerState<CategoryAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  // Trạng thái cho Icon/Color
  late IconData _selectedIcon;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.categoryToEdit != null;

    // Nếu đang sửa, tải dữ liệu cũ lên
    if (isEditing) {
      _titleController.text = widget.categoryToEdit!.title;
      _selectedIcon = widget.categoryToEdit!.icon;
      _selectedColor = widget.categoryToEdit!.color;
    } else {
      // Nếu là thêm mới, dùng giá trị mặc định
      _selectedIcon = Icons.fastfood;
      _selectedColor = Colors.orange;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.categoryToEdit != null;

      final categoryData = CategoryModel(
        // RẤT QUAN TRỌNG: Giữ lại ID nếu đang sửa
        id: isEditing ? widget.categoryToEdit!.id : null,
        title: _titleController.text,
        icon: _selectedIcon,
        color: _selectedColor,
      );

      final service = ref.read(firestoreServiceProvider);

      if (isEditing) {
        // GỌI HÀM SỬA
        service.updateCategory(categoryData);
      } else {
        // GỌI HÀM THÊM MỚI
        service.addCategory(categoryData);
      }

      // Đóng màn hình
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'SỬA DANH MỤC' : 'THÊM DANH MỤC MỚI'),
        backgroundColor: Colors.indigo[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 1. NHẬP TÊN DANH MỤC
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tên Danh Mục'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên danh mục!' : null,
              ),
              const SizedBox(height: 30),

              // 2. WIDGET CHỌN ICON VÀ MÀU
              ColorIconPicker(
                selectedIcon: _selectedIcon,
                selectedColor: _selectedColor,
                onSelected: (icon, color) {
                  setState(() {
                    _selectedIcon = icon;
                    _selectedColor = color;
                  });
                },
              ),
              const SizedBox(height: 50),

              // 3. NÚT LƯU
              ElevatedButton(
                onPressed: _submitData,
                child: Text(isEditing ? 'LƯU THAY ĐỔI' : 'THÊM DANH MỤC'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}