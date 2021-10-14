import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:get_book_isbn/models/book_data.dart';
import 'package:get_book_isbn/models/library_data_has_book.dart';
import 'package:get_book_isbn/models/library_model.dart';
import 'package:http/http.dart' as http;
import 'constraints.dart';

///Freezedでの処理
final dioProvider = Provider((ref) => Dio());
//final repositoryProvider = Provider<RepositoryFromRakuten>((ref) => RepositoryFromRakuten(ref.read));

// class RepositoryFromRakuten {
//   RepositoryFromRakuten(this._read);
//
//   final Reader _read;
//   final int Function() _getCurrentTimeStamp;
//   final _cache = <String, >;
//
//   // 取得処理
//   Future<BookFromRakuten> _get(
//       String path, {
//         Map<String, Object?>? queryParameters,
//         CancelToken? cancelToken,
//       }) async {
//
//     // APIキーのモデルクラスのプロバイダーを取得
//     // FeatureProviderで定義してるのでprovider.futureをreadする
//     final configs = await _read(configurationsProvider.future);
//
//     // dioパッケージのメソッドでリクエストを送る
//     // 取得した日時
//     final timestamp = _getCurrentTimestamp();
//     // 日時とAPIキーを使ってハッシュ(暗号文字)作成
//     final hash = md5
//         .convert(
//       utf8.encode('$timestamp${configs.privateKey}${configs.publicKey}'),
//     )
//         .toString();
//
//     // dioパッケージからレスポンスをDioクラスとして取得
//     // パラメータに好きな情報を保存できる。今回は日時、キー、ハッシュ、その他
//     final result = await _read(dioProvider).get<Map<String, Object?>>(
//       'https://gateway.marvel.com/v1/public/$path',
//       cancelToken: cancelToken,
//       queryParameters: <String, Object?>{
//         'apikey': configs.publicKey,
//         'ts': timestamp,
//         'hash': hash,
//         ...?queryParameters, // 引数に指定したパラメータをセット。ない場合はNull。
//       },
//       // TODO deserialize error message
//     );
//     // レスポンスを返却
//     return MarvelResponse.fromJson(Map<String, Object>.from(result.data!));
//   }
// }

///

// タイトルの入力情報
final inputTextProvider = StateNotifierProvider((ref) => InputTextState());

class InputTextState extends StateNotifier<String> {
  InputTextState() : super("");

  void changeState(newState) => state = newState;
}

// 検索するISBN
final getISBNProvider =
    StateNotifierProvider<GetISBNNotifier, String>((ref) => GetISBNNotifier());

class GetISBNNotifier extends StateNotifier<String> {
  GetISBNNotifier() : super('');

  void changeState(newISBN) => state = newISBN;
}

final testISBNProvider = Provider<String>((ref) {
  return '';
});

// 検索結果を一気に取得する
final testGetProvider = FutureProvider<List<LibraryModel>>((ref) async {
  print('検索開始');
  final isbn = ref.watch(getISBNProvider);
  if (isbn == '') {
    print('空欄のため検索しない');
    return [];
  }
  final repo = ref.read(testRepoProvider);
  final Position position = await repo.getLocation();
  final libraries = await repo.getLibraryFromPosition(position);
  print('libraries.length = ${libraries.length}');
  final libKeys = await repo.getSystemIdList(libraries);
  print(libKeys);
  final libData = await repo.searchBooksInLibraries(libKeys, isbn);
  for (var lib in libData) {
    print('libkey: ${lib.libkey}, status: ${lib.status}');
  }
  final libDataHasBook = await repo.getHasBookData(libData);
  print(libDataHasBook);
  final showLibraries = repo.getShowLibraries(libraries, libDataHasBook);
  print(showLibraries);
  print('検索完了');
  return showLibraries;
});

final testRepoProvider = Provider((ref) {
  return TestRepo();
});

// 検索処理を定義したクラス
class TestRepo {
  Future<Position> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
    return position;
  }

  Future<List<LibraryModel>> getLibraryFromPosition(Position position) async {
    // 何故かGPSの値がおかしい。治るまで手動で指定している
    // final longitude = position.longitude;
    // final latitude = position.latitude;

    final dynamic getLibraryData;
    var url = Uri.parse(
        'https://api.calil.jp/library?appkey=$apiKey&geocode=$longitude,$latitude&limit=$searchLibraryCount&callback=&format=json');
    http.Response _response = await http.get(url);
    if (_response.statusCode == 200) {
      getLibraryData = jsonDecode(_response.body);
    } else {
      print('エラー発生。エラーコード：${_response.statusCode}');
      getLibraryData = null;
    }

    // モデル化してリストに格納
    List<LibraryModel> list = [];
    for (var lib in getLibraryData) {
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
    // 更新
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

  // ISNBを使って図書館を検索
// sessionの有無でURLが変わる
  Future<dynamic> getLibraryUseISNB(
      {required String systemId, required String isbn, String? session}) async {
    Uri url;
    if (session != null) {
      url = Uri.parse(
          'https://api.calil.jp/check?session=$session&appkey=$apiKey&isbn=$isbn&systemid=$systemId&format=json&callback=no');
    } else {
      url = Uri.parse(
          'https://api.calil.jp/check?appkey=$apiKey&isbn=$isbn&systemid=$systemId&format=json&callback=no');
    }
    http.Response _response = await http.get(url);
    if (_response.statusCode == 200) {
      return jsonDecode(_response.body);
    } else {
      print('エラー発生。エラーコード：${_response.statusCode}');
      return null;
    }
  }

  // 検索結果の中で本がある図書館のデータのみに絞り込んでリストを更新
  Future<List<LibraryDataHasBook>> getHasBookData(
      List<LibraryDataHasBook> librariesHasBook) async {
    return librariesHasBook
        .where((lib) => lib.status != "Error" && lib.libkey!.values.isNotEmpty)
        .toList();
  }

  // 読み込みが完了した状態で検索結果を取得
  Future<dynamic> getCompletedLibraryFromISNB({
    required String isbn,
    required List<String> libKeys,
  }) async {
    var results = [];

    for (var libKey in libKeys) {
      final response = await getLibraryUseISNB(isbn: isbn, systemId: libKey);
      results.add(response);
    }

    while (results.where((result) => result['continue'] == 1).isNotEmpty) {
      await Future.delayed(const Duration(seconds: 2));
      results.asMap().forEach((index, result) async {
        if (result['continue'] == 1) {
          results[index] = await getLibraryUseISNB(
              isbn: isbn, systemId: result['id'], session: result['session']);
        }
      });

    }


    return results;
    // var getData = await getLibraryUseISNB(systemId: systemId, isbn: isbn);
    // // continueが1(読み込み中)の場合は再度検索する
    // while (getData['continue'] == 1) {
    //   getData = await getLibraryUseISNB(
    //       systemId: systemId,isbn: isbn, session: getData['session']);
    // }
    // return getData;
  }

  // システムIDを使って本を検索しモデル化してリストを更新
  Future<List<LibraryDataHasBook>> searchBooksInLibraries(
      List<String> libKeys, String isbn) async {
    List<LibraryDataHasBook> list = [];
    final response =
        await getCompletedLibraryFromISNB(isbn: isbn, libKeys: libKeys);
    var index = 0;
    for (var data in response) {
      var libKey = libKeys[index];
      list.add(LibraryDataHasBook(
          systemId: libKey,
          status: data['books'][isbn][libKey]['status'],
          libkey: data['books'][isbn][libKey]['libkey'],
          url: data['books'][isbn][libKey]['reserveurl']));
      index++;
    }
    return list;
    // List<LibraryDataHasBook> list = [];
    // for (var systemId in libKeys) {
    //   var library =
    //       await getCompletedLibraryFromISNB(isbn: isbn, systemId: systemId);
    //   list.add(LibraryDataHasBook(
    //       systemId: systemId,
    //       status: library['books'][isbn][systemId]['status'],
    //       libkey: library['books'][isbn][systemId]['libkey'],
    //       url: library['books'][isbn][systemId]['reserveurl']));
    // }
    // return list;
  }

  // 周辺の図書館から本がある図書館を探してリスト化し表示
  List<LibraryModel> getShowLibraries(
      List<LibraryModel> libraries, List<LibraryDataHasBook> hasBookData) {
    List<LibraryModel> list = [];
    for (var lib in libraries) {
      for (var data in hasBookData) {
        String libkeyName = data.libkey!.keys.cast<String>().first;
        if (lib.systemId == data.systemId && lib.libkey == libkeyName) {
          lib.status = data.libkey;
          lib.bookPageURL = data.url;

          list.add(lib);
        }
      }
    }
    return list;
  }
}

// 楽天APIに対するプロバイダーとNotifier。これは正常に動く。
final getBookFromRakutenProvider =
    StateNotifierProvider<GetBookFromRakutenState, List<BookFromRakuten>>(
        (ref) => GetBookFromRakutenState());

class GetBookFromRakutenState extends StateNotifier<List<BookFromRakuten>> {
  GetBookFromRakutenState() : super([]);

  // 楽天のAPIへリクエスト送信
  Future<dynamic> getBookFromRakuten(String title) async {
    var url = Uri.parse(
        'https://app.rakuten.co.jp/services/api/BooksTotal/Search/20170404?format=json&keyword=$title&booksGenreId=001&hits=10&applicationId=$appId');
    http.Response _response = await http.get(url);
    if (_response.statusCode == 200) {
      return jsonDecode(_response.body);
    } else {
      print('エラー発生。エラーコード：${_response.statusCode}');
      return null;
    }
  }

  // レスポンスをモデル化しリストに格納
  Future<void> getListSearchedTitle(title) async {
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
    state = result;
  }
}
