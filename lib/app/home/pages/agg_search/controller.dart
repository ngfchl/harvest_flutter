import 'package:get/get.dart';
import 'package:tmdb_api/tmdb_api.dart';

class AggSearchController extends GetxController {
  late TMDB tmdb;

  @override
  void onInit() {
    initTmdbInstance();
    super.onInit();
  }

  initTmdbInstance() async {
    String tmdbKey = '3e01686b5337f103b0153cb3451e421f';
    String tmdbToken =
        'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzZTAxNjg2YjUzMzdmMTAzYjAxNTNjYjM0NTFlNDIxZiIsInN1YiI6IjYyMzE1MDA3ZDhmNDRlMDA0NjJhYWFiYSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.k9FAzVGDo4ZVjakroh8pleAw9OEp8WcoWYW9YBpNVlM';
    ApiKeys apiKeys = ApiKeys(tmdbKey, tmdbToken);

    tmdb = TMDB(apiKeys, defaultLanguage: 'zh-CN');

    update();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
