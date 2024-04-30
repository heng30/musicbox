import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NoFound extends StatefulWidget {
  const NoFound({super.key});

  @override
  State<NoFound> createState() => _NoFoundState();
}

class _NoFoundState extends State<NoFound> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("No Found 404"),
      ),
      body: ElevatedButton(
        onPressed: () {
          Get.offAllNamed("/");
        },
        child: const Text("回到首页"),
      ),
    );
  }
}
