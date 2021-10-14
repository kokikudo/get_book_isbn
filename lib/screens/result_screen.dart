import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:get_book_isbn/utils/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends HookWidget {
  const ResultScreen({Key? key}) : super(key: key);

  // ブラウザに飛ぶ処理
  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'URLが正しくありません';

  @override
  Widget build(BuildContext context) {
    final _result = useProvider(testGetProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('検索結果'),
      ),
      body: _result.when(
        data: (libraries) {
          return libraries.isNotEmpty
              ? ListView.builder(
                  itemCount: libraries.length,
                  itemBuilder: (context, int index) {
                    final library = libraries[index];
                    return Card(
                      child: Column(
                        children: [
                          Text(library.formalName),
                          Text(library.post),
                          Text(library.address),
                          Text(library.distance.toString()),
                          Text(library.status!.values.toString()),
                          TextButton(
                              onPressed: () => _launchURL(library.bookPageURL!),
                              child: Text(library.bookPageURL.toString())),
                        ],
                      ),
                    );
                  })
              : Center(
                  child: Text('周辺の図書館にこの本はありません'),
                );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Text('Error $err'),
      ),
    );
  }
}
