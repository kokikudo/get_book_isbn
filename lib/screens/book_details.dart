import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_book_isbn/utils/provider.dart';
import 'package:get_book_isbn/widgets/book_image_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BookDetailsScreen extends HookWidget {
  const BookDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final book = useProvider(bookStatusProvider);
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
            OutlinedButton(onPressed: (){}, child: Text('本の詳細ページ(カーネル)')),
            ElevatedButton(onPressed: (){

            }, child: Text('検索する')),
          ],
        ),
      ),
    );
  }
}
