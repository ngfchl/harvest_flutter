import 'package:get/get.dart';

import '../../middleware/login_middleware.dart';
import '../home/home_binding.dart';
import '../home/home_view.dart';
import '../login/login_binding.dart';
import '../login/login_view.dart';
// import '../search/search_binding.dart';
// import '../search/search_view.dart';
// import '../torrent/torrent_binding.dart';
// import '../torrent/torrent_view.dart';

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
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    // GetPage(
    //   name: _Paths.SEARCH,
    //   page: () => const SearchView(),
    //   binding: SearchBinding(),
    //   middlewares: [
    //     LoginMiddleware(),
    //   ],
    // ),
    // GetPage(
    //   name: _Paths.TORRENT,
    //   page: () => const TorrentView(),
    //   binding: TorrentBinding(),
    // ),
  ];
}
