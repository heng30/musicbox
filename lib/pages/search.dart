import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';
import '../widgets/searchbar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controllerSearch = TextEditingController();
  final FocusNode _focusNodeSearch = FocusNode();

  Widget _buildTitle(BuildContext context) {
    const searchHeight = 34.0;
    return Row(
      children: [
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: searchHeight),
            child: CSearchBar(
              height: searchHeight,
              controller: _controllerSearch,
              focusNode: _focusNodeSearch,
              onSubmitted: (value) {},
              hintText: "请输入关键字".tr,
            ),
          ),
        ),
        SizedBox(width: CTheme.margin * 4),
        GestureDetector(
          onTap: () {},
          child: Text("搜索".tr, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: CTheme.background,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: CTheme.background,
          centerTitle: true,
          title: _buildTitle(context),
        ),
        body: _buildBody(context),
      ),
    );
  }
}
