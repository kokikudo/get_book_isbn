import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_book_isbn/utils/my_method.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:get_book_isbn/utils/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

final progressValueProvider =
    StateNotifierProvider<ProgressValueNotifier, double>(
        (ref) => ProgressValueNotifier());

class ProgressValueNotifier extends StateNotifier<double> {
  ProgressValueNotifier() : super(0.0);

  void changeState(newValue) {
    state = newValue;
    print(state);
    if (state == 1.0) {
      state = 0.0;
    }
  }
}

class ResultScreen extends HookWidget {
  const ResultScreen({Key? key}) : super(key: key);

  // URL先へ移動

  @override
  Widget build(BuildContext context) {
    final _result = useProvider(testGetProvider);
    final _progressValue = useProvider(progressValueProvider);
    final _loadingWidgetSize = MediaQuery.of(context).size;
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

                    final urlToGoogleMap =
                        'https://www.google.com/maps/search/?api=1&query=$longitude,$latitude';
                    return Card(
                      child: Column(
                        children: [
                          Text(library.formalName),
                          Text(library.post),
                          Text(library.address),
                          Text(library.distance.toString()),
                          Text(library.status!),
                          TextButton(
                              onPressed: () => launchURL(library.bookPageURL!),
                              child: Text(library.bookPageURL.toString())),
                          ElevatedButton(
                              onPressed: () => launchURL(urlToGoogleMap),
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
        loading: () => Center(
          child: SizedBox(
            width: _loadingWidgetSize.width / 4,
            height: _loadingWidgetSize.height / 4,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SpinKitPouringHourGlassRefined(
                    color: Colors.teal),
                SizedBox(height: 30),
                LinearProgressIndicator(
                    value: _progressValue,
                    color: Colors.teal,
                    backgroundColor: Colors.teal.shade100),
              ],
            ),
          ),
        ),
        error: (err, stack) => Text('Error $err'),
      ),
    );
  }
}
