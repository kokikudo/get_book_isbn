import 'package:flutter/material.dart';
import 'package:get_book_isbn/models/book_data.dart';

class BookImageWidget extends StatelessWidget {
  const BookImageWidget({
    Key? key,
    required this.book,required this.height,required this.width,
  }) : super(key: key);

  final BookFromRakuten book;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: book.isbn,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: NetworkImage(book.imageURL), fit: BoxFit.contain),
        ),
      ),
    );
  }
}
