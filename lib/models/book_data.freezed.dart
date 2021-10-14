// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides

part of 'book_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$BookFromRakuten2TearOff {
  const _$BookFromRakuten2TearOff();

  _BookFromRakuten2 call(
      {required String imageURL, required String title, required String isbn}) {
    return _BookFromRakuten2(
      imageURL: imageURL,
      title: title,
      isbn: isbn,
    );
  }
}

/// @nodoc
const $BookFromRakuten2 = _$BookFromRakuten2TearOff();

/// @nodoc
mixin _$BookFromRakuten2 {
  String get imageURL => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get isbn => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BookFromRakuten2CopyWith<BookFromRakuten2> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookFromRakuten2CopyWith<$Res> {
  factory $BookFromRakuten2CopyWith(
          BookFromRakuten2 value, $Res Function(BookFromRakuten2) then) =
      _$BookFromRakuten2CopyWithImpl<$Res>;
  $Res call({String imageURL, String title, String isbn});
}

/// @nodoc
class _$BookFromRakuten2CopyWithImpl<$Res>
    implements $BookFromRakuten2CopyWith<$Res> {
  _$BookFromRakuten2CopyWithImpl(this._value, this._then);

  final BookFromRakuten2 _value;
  // ignore: unused_field
  final $Res Function(BookFromRakuten2) _then;

  @override
  $Res call({
    Object? imageURL = freezed,
    Object? title = freezed,
    Object? isbn = freezed,
  }) {
    return _then(_value.copyWith(
      imageURL: imageURL == freezed
          ? _value.imageURL
          : imageURL // ignore: cast_nullable_to_non_nullable
              as String,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isbn: isbn == freezed
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$BookFromRakuten2CopyWith<$Res>
    implements $BookFromRakuten2CopyWith<$Res> {
  factory _$BookFromRakuten2CopyWith(
          _BookFromRakuten2 value, $Res Function(_BookFromRakuten2) then) =
      __$BookFromRakuten2CopyWithImpl<$Res>;
  @override
  $Res call({String imageURL, String title, String isbn});
}

/// @nodoc
class __$BookFromRakuten2CopyWithImpl<$Res>
    extends _$BookFromRakuten2CopyWithImpl<$Res>
    implements _$BookFromRakuten2CopyWith<$Res> {
  __$BookFromRakuten2CopyWithImpl(
      _BookFromRakuten2 _value, $Res Function(_BookFromRakuten2) _then)
      : super(_value, (v) => _then(v as _BookFromRakuten2));

  @override
  _BookFromRakuten2 get _value => super._value as _BookFromRakuten2;

  @override
  $Res call({
    Object? imageURL = freezed,
    Object? title = freezed,
    Object? isbn = freezed,
  }) {
    return _then(_BookFromRakuten2(
      imageURL: imageURL == freezed
          ? _value.imageURL
          : imageURL // ignore: cast_nullable_to_non_nullable
              as String,
      title: title == freezed
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      isbn: isbn == freezed
          ? _value.isbn
          : isbn // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_BookFromRakuten2
    with DiagnosticableTreeMixin
    implements _BookFromRakuten2 {
  const _$_BookFromRakuten2(
      {required this.imageURL, required this.title, required this.isbn});

  @override
  final String imageURL;
  @override
  final String title;
  @override
  final String isbn;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'BookFromRakuten2(imageURL: $imageURL, title: $title, isbn: $isbn)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'BookFromRakuten2'))
      ..add(DiagnosticsProperty('imageURL', imageURL))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('isbn', isbn));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _BookFromRakuten2 &&
            (identical(other.imageURL, imageURL) ||
                const DeepCollectionEquality()
                    .equals(other.imageURL, imageURL)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.isbn, isbn) ||
                const DeepCollectionEquality().equals(other.isbn, isbn)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(imageURL) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(isbn);

  @JsonKey(ignore: true)
  @override
  _$BookFromRakuten2CopyWith<_BookFromRakuten2> get copyWith =>
      __$BookFromRakuten2CopyWithImpl<_BookFromRakuten2>(this, _$identity);
}

abstract class _BookFromRakuten2 implements BookFromRakuten2 {
  const factory _BookFromRakuten2(
      {required String imageURL,
      required String title,
      required String isbn}) = _$_BookFromRakuten2;

  @override
  String get imageURL => throw _privateConstructorUsedError;
  @override
  String get title => throw _privateConstructorUsedError;
  @override
  String get isbn => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$BookFromRakuten2CopyWith<_BookFromRakuten2> get copyWith =>
      throw _privateConstructorUsedError;
}
