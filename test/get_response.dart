import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_book_isbn/models/library_model.dart';
import 'package:get_book_isbn/models/book_data.dart';
import 'package:http/http.dart' as http;
import 'package:get_book_isbn/models/library_data_has_book.dart';

const appId = '1081246808762900104';
//const appSecret = '17b52523544c54c05dfd4ee9f0a6b81e5ad59352';
const apiKey = 'AIzaSyCAsSKKnbVWfIcDd1F-DmVMgF0fWJSCt60';
const latitude = '35.56401833333334';
const longitude = '139.386895';
const searchLibraryCount = 100;

String inputTitle = '';
String isbn = '9784478025819';
List<BookFromRakuten> searchedBooks = [];
List<String> systemIdList = [];
List<LibraryModel> libraries = [];
List<LibraryDataHasBook> bookDataResult = [];
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

// GPS周辺の図書館のjsonデータ取得
Future<dynamic> getLibrariesJsonDataUsePosition() async {
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

// GPS周辺の図書館のjsonデータをモデル化しリストに格納
Future<void> getLibrariesUsePosition() async {
  final libraryData = await getLibrariesJsonDataUsePosition();
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
  await getLibrariesUsePosition();
  for (var lib in libraries) {
    list.add(lib.systemId);
  }
  systemIdList = list.toSet().toList();
}

// ISNBを使って図書館を検索
Future<dynamic> getLibraryUseISNB({String? systemId, String? session}) async {
  Uri url;
  if (session != null && systemId == null) {
    url = Uri.parse(
        'https://api.calil.jp/check?session=$session&format=json&callback=no');
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
// 全てのレスポンスのロードが完了するまで再ロードする
Future<dynamic> getCompletedLoadingSearchResult() async {
  var results = [];
  for (var systemId in systemIdList) {
    final response = await getLibraryUseISNB(systemId: systemId);
    results.add(response);
  }

  while (results.where((result) => result['continue'] == 1).isNotEmpty) {
    print('continue = 1 のため再取得開始');
    await Future.delayed(const Duration(seconds: 5));
    results.asMap().forEach((index, result) async {
      if (result['continue'] == 1) {
        results[index] = await getLibraryUseISNB(session: result['session']);
      }
    });
  }

  return results;
}

// システムIDを使って本を検索しモデル化してリストを更新
Future<void> searchAllBookData() async {
  List<LibraryDataHasBook> list = [];
  final response = await getCompletedLoadingSearchResult();
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
  bookDataResult = list;
}

// 検索結果の中で本がある図書館のデータのみに絞り込んでリストを更新
Future<void> getDataOnlyHasBook() async {
  bookDataResult = bookDataResult
      .where((lib) => lib.status != "Error" && lib.libkey!.values.isNotEmpty)
      .toList();
}

// 周辺の図書館から本がある図書館を探してリスト化し表示
void getShowLibraries() {
  List<LibraryModel> list = [];
  for (var lib in libraries) {
    for (var data in bookDataResult) {
      if (lib.systemId == data.systemId) {
        print('id一致したよ');
        data.libkey!.forEach((key, value) {
          if (lib.libkey == key) {
            lib.status = value;
            lib.bookPageURL = data.url;
            list.add(lib);
          }
        });
      } else {
        print('id一致してないよー；；');
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
    final result = await getLibrariesJsonDataUsePosition();
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
    await searchAllBookData();
    for (var lib in bookDataResult) {
      print(
          'id: ${lib.systemId}, status: ${lib.status}, url: ${lib.url}, libkey: ${lib.libkey}');
    }
  });

  test('システムIDごとにお目当ての本があるか検索', () async {
    await searchAllBookData();
    await getDataOnlyHasBook();
    bookDataResult.asMap().forEach((int i, LibraryDataHasBook data) {
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
    await getLibrariesUsePosition();

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
    await searchAllBookData();
    await getDataOnlyHasBook();

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
    await getLibrariesUsePosition();
    print(libraries[0].formalName);
  });

  test('先にロード中の結果も含めたレスポンスを取得し、後でロード中のレスポンスだけ再リクエストする', () async {
    await searchAllBookData();
    for (var lib in bookDataResult) {
      print('''
      ----------------
      ${lib.systemId}, ${lib.status}, ${lib.libkey}, ${lib.url}
      ''');
    }
  });

  test('システムIDごとに本の検索', () async {
    systemIdList = [
      'Kanagawa_Sagamihara',
      'Univ_Azabu',
      'Special_Jaxa',
      'Univ_Aoyamagakuin',
      'Univ_Kitasato',
      'Univ_Obirin',
      'Univ_Joshibi',
      'Tokyo_Machida',
      'Univ_Yamazaki',
      'Tokyo_Hachioji',
      'Univ_Tmu',
      'Univ_Otsuma',
      'Univ_Salesio',
      'Tokyo_Tama',
      'Univ_Sagami_Wu',
      'Univ_Tamabi',
      'Kanagawa_Atsugi',
      'Kanagawa_Zama',
      'Univ_Toyaku',
      'Univ_Keisen',
      'Univ_Chuo',
      'Univ_Yamano',
      'Tokyo_Hino',
      'Kanagawa_Aikawa',
      'Univ_Teu',
      'Univ_Meisei',
      'Univ_Zokei',
      'Univ_Teikyo',
      'Univ_Kokushikan',
      'Kanagawa_Yamato',
      'Univ_Kait',
      'Univ_Nms',
      'Kanagawa_Ebina',
      'Univ_Tamagawa',
      'Univ_Jissen'
    ];

    await searchAllBookData();
    bookDataResult.asMap().forEach((int i, LibraryDataHasBook data) {
      print('no.${i + 1}----------');
      print("""
      systemid: ${data.systemId}
      status: ${data.status}
      url: ${data.url}
      libkey: ${data.libkey}
      """);
    });
  });

  test('周辺の図書館の取得〜本がある図書館を表示まで一致に処理する', () async {
    await getLibrariesUsePosition();
    await getSystemIdList();
    print(systemIdList);
    isbn = '4776209470';
    await searchAllBookData();
    await getDataOnlyHasBook();
    bookDataResult.asMap().forEach((int i, LibraryDataHasBook data) {
      print('no.${i + 1}----------');
      print("""
      systemid: ${data.systemId}
      status: ${data.status}
      url: ${data.url}
      libkey: ${data.libkey}
      """);
    });
    getShowLibraries();
    print('--------図書館別に表示-----------');
    showLibraries.asMap().forEach((int i, LibraryModel lib) {
      print('no.${i + 1}----------');
      print("""
      systemid: ${lib.systemId}
      status: ${lib.status}
      url: ${lib.bookPageURL}
      libkey: ${lib.libkey}
      """);
    });
  });
}
