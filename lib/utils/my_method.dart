import 'package:url_launcher/url_launcher.dart';

// 外部リンクへ移動
void launchURL(String url) async {
  await canLaunch(url)
      ? await launch(url, forceSafariVC: false)
      : throw 'URLが正しくありません';
}