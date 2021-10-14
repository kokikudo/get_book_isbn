import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_book_isbn/models/library_model.dart';
import 'package:get_book_isbn/models/book_data.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:get_book_isbn/models/library_data_has_book.dart';

const appId = '1081246808762900104';
const appSecret = '17b52523544c54c05dfd4ee9f0a6b81e5ad59352';
const apiKey = 'AIzaSyCAsSKKnbVWfIcDd1F-DmVMgF0fWJSCt60';
const latitude = '35.56401833333334';
const longitude = '139.386895';
const searchLibraryCount = 100;

String inputTitle = '';
String isbn = '9784478025819';
List<BookFromRakuten> searchedBooks = [];
List<String> systemIdList = [];
List<LibraryModel> libraries = [];
List<LibraryDataHasBook> testLibrariesHasBookData = [];
List<LibraryModel> showLibraries = [];

// 本のタイトル　→　楽天APIの結果
Future<dynamic> getJsonFromRakuten() async {
  var url = Uri.parse(
      'https://app.rakuten.co.jp/services/api/BooksTotal/Search/20170404?format=json&keyword=$inputTitle&booksGenreId=001&hits=10&applicationId=$appId');
  http.Response _response = await http.get(url);
  if (_response.statusCode == 200) {
    return jsonDecode(_response.body);
  } else {
    print('エラー発生。エラーコード：${_response.statusCode}');
    return null;
  }
}

// レスポンスをモデル化しリストに格納
Future<void> getListSearchedTitle() async {
  var data = await getJsonFromRakuten();
  List<dynamic> items = data['Items'];
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
  searchedBooks = result;
}

// ISNBを使って図書館を検索
// sessionの有無でURLが変わる
Future<dynamic> getLibraryUseISNB(
    {required String systemId, String? session}) async {
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

// 読み込みが完了した状態で検索結果を取得
Future<dynamic> getCompletedLibraryFromISNB({
  required String isbn,
  required String systemId,
}) async {
  var getData = await getLibraryUseISNB(systemId: systemId);
  // continueが1(読み込み中)の場合は再度検索する
  while (getData['continue'] == 1) {
    getData = await getLibraryUseISNB(
        systemId: systemId, session: getData['session']);
  }
  return getData;
}

Future<dynamic> newGetLibrariesFromISBN(List<String> libKeys) async {
  var results = [];
  for (var libKey in libKeys) {
    final response = await getLibraryUseISNB(systemId: libKey);
    results.add(response);
  }

  results.asMap().forEach((index, result) async {
    if (result['continue'] == 1) {
      results[index] = await getLibraryUseISNB(
          systemId: result['id'], session: result['session']);
    }
  });

  return results;
}

// GPS周辺の図書館のデータを取得
Future<dynamic> getLibraryFromPosition() async {
  var url = Uri.parse(
      'https://api.calil.jp/library?appkey=$apiKey&geocode=$longitude,$latitude&limit=$searchLibraryCount&callback=&format=json');
  http.Response _response = await http.get(url);
  if (_response.statusCode == 200) {
    return jsonDecode(_response.body);
  } else {
    print('エラー発生。エラーコード：${_response.statusCode}');
    return null;
  }
}

// GPS周辺の図書館のデータをモデル化しリストに格納
Future<dynamic> testGetLibraryFromPosition() async {
  final libraryData = await getLibraryFromPosition();
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
  libraries = list;
}

// システムIDの種類をリストに格納
Future<void> getSystemIdList() async {
  List<String> list = [];
  await testGetLibraryFromPosition();
  for (var lib in libraries) {
    list.add(lib.systemId);
  }
  systemIdList = list.toSet().toList();
}

// システムIDを使って本を検索しモデル化してリストを更新
Future<void> searchBooksInLibraries() async {
  await getSystemIdList();
  List<LibraryDataHasBook> list = [];
  final response = await newGetLibrariesFromISBN(systemIdList);
  var index = 0;
  for (var data in response) {
    var libKey = systemIdList[index];
    list.add(LibraryDataHasBook(
        systemId: libKey,
        status: data['books'][isbn][libKey]['status'],
        libkey: data['books'][isbn][libKey]['libkey'],
        url: data['books'][isbn][libKey]['reserveurl']));
    index ++;
  }
  // for (var systemId in systemIdList) {
  //   var library =
  //       await getCompletedLibraryFromISNB(isbn: isbn, systemId: systemId);
  //   list.add(LibraryDataHasBook(
  //       systemId: systemId,
  //       status: library['books'][isbn][systemId]['status'],
  //       libkey: library['books'][isbn][systemId]['libkey'],
  //       url: library['books'][isbn][systemId]['reserveurl']));
  // }
  testLibrariesHasBookData = list;
}

// 検索結果の中で本がある図書館のデータのみに絞り込んでリストを更新
Future<void> getHasBookData() async {
  await searchBooksInLibraries();
  testLibrariesHasBookData = testLibrariesHasBookData
      .where((lib) => lib.status != "Error" && lib.libkey!.values.isNotEmpty)
      .toList();
}

// 周辺の図書館から本がある図書館を探してリスト化し表示
void getShowLibraries() {
  List<LibraryModel> list = [];
  for (var lib in libraries) {
    for (var data in testLibrariesHasBookData) {
      String libkeyName = data.libkey!.keys.cast<String>().first;
      if (lib.systemId == data.systemId && lib.libkey == libkeyName) {
        lib.status = data.libkey;
        lib.bookPageURL = data.url;

        list.add(lib);
      }
    }
  }
  showLibraries = list;
}

void main() {
  test('楽天APIからjson取得', () async {
    inputTitle = '単純な脳';
    var result = await getJsonFromRakuten();
    expect(result, isNotNull);
    expect(result['Items'], isNotNull);
    expect(result['Items'][0], isNotNull);
    expect(result['Items'][0]['Item']['limitedFlag'], 0);
    expect(result['Items'][0]['Item']['isbn'], '9784062578301');
  });

  test('取得したデータをモデル化してリストに格納', () async {
    inputTitle = '単純な脳';
    await getListSearchedTitle();
    expect(searchedBooks.length, 9);
  });

  test('ISBN番号を引数にして図書館API使用', () async {
    inputTitle = '単純な脳';
    await getListSearchedTitle();
    isbn = searchedBooks[0].isbn;

    final libraryResult = await getLibraryUseISNB(systemId: 'Aomori_Pref');

    expect(libraryResult, isNotNull);
  });

  test('GPSをもとに周辺にある図書館のデータ取得', () async {
    final result = await getLibraryFromPosition();
    expect(result, isNotNull);

    expect(result[0]['formal'], '相模原市立図書館');
    expect(result[0]['address'], '神奈川県相模原市中央区鹿沼台2-13-1');
    expect(result[0]['geocode'], '139.3929082,35.5675674');
    expect(result[0]['distance'], 0.7329177702555214);
    expect(result[0]['systemid'], 'Kanagawa_Sagamihara');
    expect(result[0]['systemname'], '神奈川県相模原市');
  });

  test('周辺にある図書館のシステムIDを格納したリスト作成', () async {
    await getSystemIdList();
    print(systemIdList);
  });

  test('システムIDごと本の検索結果', () async {
    await searchBooksInLibraries();
    for (var lib in testLibrariesHasBookData) {
      print(
          'id: ${lib.systemId}, status: ${lib.status}, url: ${lib.url}, libkey: ${lib.libkey}');
    }
  });

  test('システムIDごとにお目当ての本があるか検索', () async {
    await searchBooksInLibraries();
    await getHasBookData();
    testLibrariesHasBookData.asMap().forEach((int i, LibraryDataHasBook data) {
      print('${i + 1}-----------');
      print("""
      id: ${data.systemId},
      status: ${data.status},
      url: ${data.url},
      libkey: ${data.libkey}
      """);
    });
  });

  test('GPS周辺の図書館を取得しデータモデル化する', () async {
    await testGetLibraryFromPosition();

    libraries.asMap().forEach((int i, LibraryModel lib) {
      print('no.${i + 1}----------');
      print("""
      systemid: ${lib.systemId}
      formalName: ${lib.formalName}
      url: ${lib.urlPc}
      address: ${lib.address}
      post: ${lib.post}
      geo:${lib.geocode}
      """);
    });
  });

  test('GPS周辺の図書館から本が置いてある図書館を取得', () async {
    await searchBooksInLibraries();
    await getHasBookData();

    getShowLibraries();
    for (var lib in showLibraries) {
      print("""
          systemid: ${lib.systemId}
        formalName: ${lib.formalName}
        bookPageURL: ${lib.bookPageURL}
        address: ${lib.address}
        post: ${lib.post}
        geo:${lib.geocode}
        status: ${lib.status}
        distance: ${lib.distance}
        """);
    }
  });

  test('周辺の図書館をモデル化しリストで取得', () async {
    await testGetLibraryFromPosition();
    print(libraries[0].formalName);
  });

  test('先にロード中の結果も含めたレスポンスを取得し、後でロード中のレスポンスだけ再リクエストする', () async {

    await searchBooksInLibraries();
    for (var lib in testLibrariesHasBookData) {
      print('''
      ----------------
      ${lib.systemId}, ${lib.status}, ${lib.libkey}, ${lib.url}
      ''');

    }
  });
}
