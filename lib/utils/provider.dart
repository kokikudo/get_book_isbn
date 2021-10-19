import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:get_book_isbn/models/book_data.dart';
import 'package:get_book_isbn/models/library_data_has_book.dart';
import 'package:get_book_isbn/models/library_model.dart';
import 'package:http/http.dart' as http;
import 'constraints.dart';

// タイトルの入力情報
final inputTextProvider = StateNotifierProvider((ref) => InputTextState());

class InputTextState extends StateNotifier<String> {
  InputTextState() : super("");

  void changeState(newState) => state = newState;
}

final getRakutenAPIProvider =
    FutureProvider<List<BookFromRakuten>>((ref) async {
  final bookTitle = ref.watch(inputTextProvider);
  if (bookTitle == '') {
    return [];
  }
  final repo = ref.read(testRepoProvider);
  final result = await repo.getListSearchedTitle(bookTitle);
  return result;
});

// 検索するISBN
final getISBNProvider =
    StateNotifierProvider<GetISBNNotifier, String>((ref) => GetISBNNotifier());

class GetISBNNotifier extends StateNotifier<String> {
  GetISBNNotifier() : super('');

  void changeState(newISBN) => state = newISBN;
}


// 検索結果を一気に取得する
final testGetProvider =
    FutureProvider.autoDispose<List<LibraryModel>>((ref) async {
  // キャンセルトークンの設定
  final token = CancelToken();
  ref.onDispose(() => token.cancel('キャンセルされました。'));

  print('-------検索開始------');
  final isbn = ref.watch(getISBNProvider);
  final repo = ref.watch(testRepoProvider);
  final Position position = await repo.getLocation();
  final List<LibraryModel> libraries =
      await repo.getLibrariesUsePosition(position);
  final List<String> systemIdList = await repo.getSystemIdList(libraries);

  print('''
  ---------検索前の情報-----------
  isbn: $isbn,
  Position: $position,
  libraries: ${libraries.length}
  systemIdList: ${systemIdList.length},
  ''');
  List<LibraryDataHasBook> bookDataResult =
      await repo.searchAllBookData(systemIdList, isbn, token);
  bookDataResult = await repo.getDataOnlyHasBook(bookDataResult);
  final List<LibraryModel> showLibraries =
      repo.getShowLibraries(libraries, bookDataResult);

  print('-------検索完了------');
  return showLibraries;
});

final testRepoProvider = Provider((ref) {
  return TestRepo();
});

// 検索処理を定義したクラス
class TestRepo {
  // 楽天のAPIへリクエスト送信
  Future<dynamic> getBookFromRakuten(String title) async {
    var url = Uri.parse(
        'https://app.rakuten.co.jp/services/api/BooksTotal/Search/20170404?format=json&keyword=$title&booksGenreId=001&hits=30&applicationId=$appId');
    http.Response _response = await http.get(url);
    if (_response.statusCode == 200) {
      return jsonDecode(_response.body);
    } else {
      print('エラー発生。エラーコード：${_response.statusCode}');
      return null;
    }
  }

  // レスポンスをモデル化しリストに格納
  Future<List<BookFromRakuten>> getListSearchedTitle(title) async {
    final data = await getBookFromRakuten(title);
    final items = data['Items'];
    List<BookFromRakuten> result = [];
    for (var item in items) {
      result.add(
        BookFromRakuten(
          imageURL: item['Item']['mediumImageUrl'],
          title: item['Item']['title'],
          isbn: item['Item']['isbn'],
        ),
      );
    }

    // 更新
    return result;
  }

  Future<Position> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    return position;
  }

  // GPS周辺の図書館のjsonデータ取得
  Future<dynamic> getLibrariesJsonDataUsePosition(Position position) async {
    //final longitude = position.longitude;
    final longitude = 139.3869;
    //final latitude = position.latitude;
    final latitude = 35.5640;
    final url =
        'https://api.calil.jp/library?appkey=$apiKey&geocode=$longitude,$latitude&limit=$searchLibraryCount&callback=&format=json';

    final _response = await Dio().get(url);
    return _response.data;
  }

  // GPS周辺の図書館のjsonデータをモデル化しリストに格納
  Future<List<LibraryModel>> getLibrariesUsePosition(Position position) async {
    final libraryData = await getLibrariesJsonDataUsePosition(position);
    List<LibraryModel> list = [];
    for (var lib in libraryData) {
      list.add(
        LibraryModel(
          systemName: lib['systemname'],
          shortName: lib['short'],
          formalName: lib['formal'],
          urlPc: lib['url_pc'],
          address: lib['address'],
          pref: lib['pref'],
          city: lib['city'],
          post: lib['post'],
          tel: lib['tel'],
          geocode: lib['geocode'],
          category: lib['category'],
          systemId: lib['systemid'],
          libkey: lib['libkey'],
          distance: lib['distance'],
        ),
      );
    }
    return list;
  }

// システムIDの種類をリストに格納
  Future<List<String>> getSystemIdList(List<LibraryModel> libraries) async {
    List<String> list = [];
    for (var lib in libraries) {
      list.add(lib.systemId);
    }
    return list.toSet().toList();
  }

// システムIDを使って本を検索しモデル化してリストを更新
  Future<List<LibraryDataHasBook>> searchAllBookData(
      List<String> systemIdList, String isbn, CancelToken token) async {
    List<LibraryDataHasBook> list = [];
    final response =
        await getCompletedLoadingSearchResult(systemIdList, isbn, token);
    var index = 0;
    for (var data in response) {
      var libKey = systemIdList[index];
      list.add(LibraryDataHasBook(
          systemId: libKey,
          status: data['books'][isbn][libKey]['status'],
          libkey: data['books'][isbn][libKey]['libkey'],
          url: data['books'][isbn][libKey]['reserveurl']));
      index++;
    }
    return list;
  }

  // ISNBを使って図書館を検索
  Future<dynamic> getLibraryUseISNB(
      {String? isbn,
      String? systemId,
      String? session,
      CancelToken? token}) async {
    String url;
    if (session != null && systemId == null && isbn == null) {
      url =
          'https://api.calil.jp/check?session=$session&format=json&callback=no';
    } else {
      url =
          'https://api.calil.jp/check?appkey=$apiKey&isbn=$isbn&systemid=$systemId&format=json&callback=no';
    }
    var _response = await Dio().get(url, cancelToken: token);
    return _response.data;
    if (_response.statusCode == 200) {
      return jsonDecode(_response.data);
    } else {
      print('エラー発生。エラーコード：${_response.statusCode}');
      return null;
    }
  }

  // ロードが完了した図書館のjsonデータ
  Future<dynamic> getCompletedLoadingSearchResult(
      List<String> systemIdList, String isbn, CancelToken token) async {
    var results = [];
    for (var systemId in systemIdList) {
      final response = await getLibraryUseISNB(isbn: isbn, systemId: systemId);
      results.add(response);
    }

    while (results.where((result) => result['continue'] == 1).isNotEmpty) {
      print('continue = 1 のため再取得開始');
      await Future.delayed(const Duration(seconds: 3));
      int index = 0;
      for (var result in results) {
        if (result['continue'] == 1) {
          results[index] = await getLibraryUseISNB(session: result['session']);
        }
        index++;
      }
    }
    return results;
  }

// 検索結果の中で本がある図書館のデータのみに絞り込んでリストを更新
  Future<List<LibraryDataHasBook>> getDataOnlyHasBook(
      List<LibraryDataHasBook> data) async {
    return data
        .where((lib) => lib.status != "Error" && lib.libkey!.values.isNotEmpty)
        .toList();
  }

// 周辺の図書館から本がある図書館を探してリスト化し表示
  List<LibraryModel> getShowLibraries(
      List<LibraryModel> libraries, List<LibraryDataHasBook> bookDataResult) {
    List<LibraryModel> list = [];
    for (var lib in libraries) {
      for (var data in bookDataResult) {
        if (lib.systemId == data.systemId) {
          data.libkey!.forEach((key, value) {
            if (lib.libkey == key) {
              lib.status = value;
              lib.bookPageURL = data.url;
              list.add(lib);
            }
          });
        }
      }
    }
    return list;
  }
}
