import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  static Route<String> route() {
    return MaterialPageRoute(builder: (_) => const SearchPage());
  }

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _textEditingController = TextEditingController();

  String get _text => _textEditingController.text;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("City Search"),
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _textEditingController,
                decoration:
                    const InputDecoration(labelText: "City", hintText: 'Chicago'),
              ),
            ),
          ),
          IconButton(
            key: const Key("searchPage_search_iconButton"),
            onPressed: () => Navigator.of(context).pop(_text),
            icon: const Icon(
              Icons.search,
              semanticLabel: "Submit",
            ),
          )
        ],
      ),
    );
  }
}
