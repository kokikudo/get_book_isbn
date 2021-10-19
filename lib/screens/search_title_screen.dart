import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_book_isbn/models/book_data.dart';
import 'package:get_book_isbn/screens/result_screen.dart';
import 'package:get_book_isbn/utils/provider.dart';
import 'package:get_book_isbn/widgets/book_image_widget.dart';
import 'package:get_book_isbn/widgets/title_search_result_card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TitleSearchScreen extends HookWidget {
  const TitleSearchScreen({Key? key}) : super(key: key);

  Future<void> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);
  }

  @override
  Widget build(BuildContext context) {
    final _resultList = useProvider(getRakutenAPIProvider); // 検索結果のリスト

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => getLocation(),
                      icon: Icon(Icons.search),
                    ),
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          // 検索したい本のタイトルの入力情報を更新
                          context
                              .read(inputTextProvider.notifier)
                              .changeState(value);
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () async {},
                      icon: Icon(Icons.qr_code_scanner),
                    ),
                  ],
                )),
            SizedBox(
              height: 10,
            ),
            Expanded(
                child: _resultList.when(
              data: (books) {
                return books.isNotEmpty
                    ? ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, int index) {
                          return TitleSearchResultCard(book: books[index]);
                        })
                    : const Center(child: Text('No Result'));
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Text('検索に失敗しました。時間をおいた後でもう一度お試しください: $err'),
            )),
          ],
        ),
      ),
    );
  }
}
