import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
part 'book_data.freezed.dart';

class BookFromRakuten {
  final String imageURL;
  final String title;
  final String isbn;

  const BookFromRakuten({Key? key,required this.imageURL,required this.title,required this.isbn});

}

@freezed
abstract class BookFromRakuten2 with _$BookFromRakuten2 {
  const factory BookFromRakuten2({
    required String imageURL,
    required String title,
    required String isbn,
  }) = _BookFromRakuten2;
}

