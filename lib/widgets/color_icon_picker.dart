import 'package:flutter/material.dart';

// Widget này sẽ mở hộp thoại cho phép người dùng chọn màu và icon
class ColorIconPicker extends StatelessWidget {
  final IconData selectedIcon;
  final Color selectedColor;
  final Function(IconData, Color) onSelected;

  const ColorIconPicker({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Hiển thị Icon và Màu hiện tại
        Row(
          children: [
            Icon(selectedIcon, color: selectedColor, size: 30),
            const SizedBox(width: 8),
            const Text('Biểu tượng & Màu', style: TextStyle(fontSize: 16)),
          ],
        ),

        // 2. Nút bấm để mở Dialog chọn
        TextButton(
          onPressed: () => _showPicker(context),
          child: const Text('CHỌN', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showPicker(BuildContext context) {
    IconData tempIcon = selectedIcon;
    Color tempColor = selectedColor;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Chọn Biểu Tượng & Màu'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // Danh sách màu sắc cơ bản
              final List<Color> colors = [
                Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
                Colors.indigo, Colors.blue, Colors.cyan, Colors.teal,
                Colors.green, Colors.lightGreen, Colors.lime, Colors.yellow,
                Colors.amber, Colors.orange, Colors.deepOrange, Colors.brown,
                Colors.grey, Colors.blueGrey, Colors.black,
              ];
              // Danh sách icons cơ bản
              final List<IconData> icons = [
                Icons.fastfood, Icons.directions_car, Icons.work, Icons.shopping_bag,
                Icons.movie, Icons.house, Icons.school, Icons.fitness_center,
                Icons.health_and_safety, Icons.savings, Icons.laptop_chromebook,
                Icons.credit_card, Icons.pets, Icons.celebration, Icons.local_gas_station,
              ];

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hiển thị Icon đang chọn
                    Row(
                      children: [
                        Icon(tempIcon, color: tempColor, size: 36),
                        const SizedBox(width: 10),
                        Text('Đang chọn: ${tempColor.toString().substring(10, 16)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(),

                    // Chọn Icons
                    const Text('Chọn Biểu Tượng:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8.0,
                      children: icons.map((icon) => IconButton(
                        icon: Icon(icon, color: icon == tempIcon ? tempColor : Colors.grey[400]),
                        onPressed: () => setState(() => tempIcon = icon),
                      )).toList(),
                    ),
                    const Divider(),

                    // Chọn Màu
                    const Text('Chọn Màu Sắc:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: colors.map((color) => GestureDetector(
                        onTap: () => setState(() => tempColor = color),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color == tempColor ? Colors.black : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('HỦY'),
            ),
            ElevatedButton(
              onPressed: () {
                onSelected(tempIcon, tempColor);
                Navigator.of(ctx).pop();
              },
              child: const Text('CHỌN'),
            ),
          ],
        );
      },
    );
  }
}