import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("پیام‌ها"),
        centerTitle: true,
         actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "بروزرسانی",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("در حال بروزرسانی داده‌ها... 🔄")),
              );
              // اینجا بعداً می‌توانی API فراخوانی کنی
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "پیامی دریافت نشده",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
