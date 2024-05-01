import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controllerSearch = TextEditingController();
  final FocusNode focusNodeSearch = FocusNode();

  Widget _buildBody(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          constraints: const BoxConstraints(maxWidth: 300, maxHeight: 32),
          child: TextField(
            maxLines: 1,
            controller: _controllerSearch,
            focusNode: focusNodeSearch,
            autofocus: true,
            onSubmitted: (v) {},
            decoration: InputDecoration(
              hintText: "请输入关键字".tr,
              contentPadding: const EdgeInsets.all(0),
              prefixIcon: IconButton(
                icon: const Icon(Icons.search, size: 20),
                onPressed: () {},
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => _controllerSearch.clear(),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(CTheme.borderRadius * 4),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(context),
    );
  }
}
