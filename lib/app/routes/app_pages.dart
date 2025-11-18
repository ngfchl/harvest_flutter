import 'package:get/get.dart';
import 'package:harvest/app/web_view/view.dart';

import '../../middleware/login_middleware.dart';
import '../home/controller/home_binding.dart';
import '../home/home_view.dart';
import '../login/binding.dart';
import '../login/view.dart'; // import '../search/search_binding.dart';
// import '../search/search_view.dart';
import '../qbittorrent/binding.dart';
import '../qbittorrent/view.dart';
import '../torrent/binding.dart';
import '../torrent/view.dart';
import '../transmission/binding.dart';
import '../transmission/view.dart';
import '../web_view/binding.dart';

// ignore_for_file: constant_identifier_names

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      middlewares: [
        LoginMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.WEBVIEW,
      page: () => const WebViewPage(),
      binding: WebViewBinding(),
      middlewares: [
        LoginMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.TORRENT,
      page: () => const TorrentView(),
      binding: TorrentBinding(),
      middlewares: [
        LoginMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.QB,
      page: () => const QBittorrentPage(),
      binding: QBittorrentBinding(),
      middlewares: [
        LoginMiddleware(),
      ],
    ),
    GetPage(
      name: _Paths.TR,
      page: () => const TrPage(),
      binding: TrBinding(),
      middlewares: [
        LoginMiddleware(),
      ],
    ),
  ];
}
