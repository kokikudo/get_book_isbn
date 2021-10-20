import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_book_isbn/screens/book_details.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:get_book_isbn/models/book_data.dart';
import 'package:get_book_isbn/utils/provider.dart';
import 'package:get_book_isbn/widgets/book_image_widget.dart';

class TitleSearchResultCard extends HookWidget {
  const TitleSearchResultCard({
    Key? key,
    required this.book,
  }) : super(key: key);

  final BookFromRakuten book;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            BookImageWidget(book: book, height: 100, width: 100),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(book.isbn),

                  TextButton(
                    onPressed: () {
                      context.read(bookStatusProvider.notifier).changeState(
                          imageURL: book.imageURL,
                          title: book.title,
                          isbn: book.isbn);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BookDetailsScreen()),
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
