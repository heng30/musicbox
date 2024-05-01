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
      color: CTheme.background,
    );
  }

  @override
  Widget build(BuildContext context) {
    const searchHeight = 36.0;
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Row(
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: searchHeight),
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
                        icon: Icon(Icons.search,
                            size: searchHeight * 0.6, color: CTheme.primary),
                        onPressed: () {},
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear,
                            size: searchHeight * 0.6, color: CTheme.primary),
                        onPressed: () => _controllerSearch.clear(),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: CTheme.secondary,
                          width: 1,
                        ),
                        borderRadius:
                            BorderRadius.circular(CTheme.borderRadius * 4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: CTheme.primary,
                          width: 1,
                        ),
                        borderRadius:
                            BorderRadius.circular(CTheme.borderRadius * 4),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: CTheme.margin * 4),
              GestureDetector(
                onTap: () {},
                child:
                    Text("搜索".tr, style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],
          )),
      body: _buildBody(context),
    );
  }
}
