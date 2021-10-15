import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:get_book_isbn/utils/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultScreen extends HookWidget {
  const ResultScreen({Key? key}) : super(key: key);

  // URL先へ移動
  void _launchURL(String url) async {
    await canLaunch(url) ? await launch(url, forceSafariVC: false) : throw 'URLが正しくありません';
  }


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
                    final latitude = library.geocode.split(',')[0];
                    final longitude = library.geocode.split(',')[1];

                    final urlToGoogleMap = 'https://www.google.com/maps/search/?api=1&query=$longitude,$latitude';
                    // final urlToGoogleMap =
                    //     'https://www.google.com/maps/search/?api=1&query=${library.post}+${library.address}';
                    return Card(
                      child: Column(
                        children: [
                          Text(library.formalName),
                          Text(library.post),
                          Text(library.address),
                          Text(library.distance.toString()),
                          Text(library.status!),
                          TextButton(
                              onPressed: () => _launchURL(library.bookPageURL!),
                              child: Text(library.bookPageURL.toString())),
                          ElevatedButton(
                              onPressed: () => _launchURL(urlToGoogleMap),
                              child: Text('Open Google Map')),
                          Text(library.geocode)
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
