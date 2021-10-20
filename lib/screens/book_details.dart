import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_book_isbn/screens/result_screen.dart';
import 'package:get_book_isbn/utils/provider.dart';
import 'package:get_book_isbn/widgets/book_image_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:get_book_isbn/utils/my_method.dart';

class BookDetailsScreen extends HookWidget {
  const BookDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final book = useProvider(bookStatusProvider);
    const bookURL = 'https://calil.jp/book';
    final imageHeight = MediaQuery.of(context).size.height / 3;
    final imageWidth = MediaQuery.of(context).size.width / 1.5;

    return Scaffold(
      appBar: AppBar(
        title: Text('検索する本'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BookImageWidget(book: book, height: imageHeight, width: imageWidth),
            Text(book.title, textAlign: TextAlign.center),
            Text(book.isbn, textAlign: TextAlign.center),
            OutlinedButton.icon(
              onPressed: () => launchURL('$bookURL/${book.isbn}'), // カーネルサイトへ移動

              icon: Icon(Icons.logout),
              label: Text('詳細ページへ移動する'),
            ),
            ElevatedButton(
              onPressed: () async {
                context.read(getISBNProvider.notifier).changeState(book.isbn);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResultScreen()),
                );
              },
              child: Text('検索する'),
            ),
          ],
        ),
      ),
    );
  }
}
