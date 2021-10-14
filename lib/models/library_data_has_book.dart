import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'library_data_has_book.freezed.dart';

class LibraryDataHasBook {
  const LibraryDataHasBook(
      {Key? key,
        required this.systemId,
        required this.status,
        required this.libkey,
        required this.url});

  final String systemId;
  final String status;
  final Map<String, dynamic>? libkey;
  final String? url;
}

@freezed
abstract class LibraryDataHasBook2 with _$LibraryDataHasBook2 {
  const factory LibraryDataHasBook2({
    required String imageURL,
    required String title,
    required String isbn,
  }) = _LibraryDataHasBook2;
}