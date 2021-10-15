import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_book_isbn/models/book_data.dart';
import 'package:get_book_isbn/screens/result_screen.dart';
import 'package:get_book_isbn/utils/provider.dart';
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
    final _inputTitle = useProvider(inputTextProvider); // 入力中の本のタイトル
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
                        keyboardType: TextInputType.name,
                        onSubmitted: (value) {
                          // 検索したい本のタイトルの入力情報を更新
                          context
                              .read(inputTextProvider.notifier)
                              .changeState(value);
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        // タイトルを引数にして楽天APIから本の情報を取得
                        // await context
                        //     .read(getBookFromRakutenProvider.notifier)
                        //     .getListSearchedTitle(_inputTitle);
                      },
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
                          return TitleSearchResultCard(books: books[index]);
                        })
                    : const Center(
                        child: Text('No Result'),
                      );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error $err'),
            )),

            // _resultList.isNotEmpty
            //     ? Expanded(
            //         child: ListView.builder(
            //             itemCount: _resultList.length,
            //             itemBuilder: (context, int index) {
            //               return TitleSearchResultCard(
            //                   books: _resultList[index]);
            //             }),
            //       )
            //     : Expanded(
            //         child: Center(
            //           child: Text('No Result'),
            //         ),
            //       )
          ],
        ),
      ),
    );
  }
}

class TitleSearchResultCard extends HookWidget {
  const TitleSearchResultCard({
    Key? key,
    required this.books,
  }) : super(key: key);

  final BookFromRakuten books;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(books.imageURL), fit: BoxFit.contain),
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    books.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(books.isbn),

                  // 検索処理を実行するボタン
                  TextButton(
                    onPressed: () {
                      // ISBN番号の更新
                      context
                          .read(getISBNProvider.notifier)
                          .changeState(books.isbn);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(),
                        ),
                      );
                    },
                    child: Text('search'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
