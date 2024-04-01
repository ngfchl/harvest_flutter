import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/logger_helper.dart';
import 'controller.dart';

class AggSearchPage extends StatefulWidget {
  const AggSearchPage({super.key});

  @override
  State<AggSearchPage> createState() => _AggSearchPageState();
}

class _AggSearchPageState extends State<AggSearchPage> {
  final controller = Get.put(AggSearchController());

  @override
  Widget build(BuildContext context) {
    final List<Tab> myTabs = <Tab>[
      const Tab(text: 'LEFT', height: 20),
      Tab(text: 'RIGHT', height: 20),
    ];
    return DefaultTabController(
      length: myTabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: myTabs,
          ),
        ),
        body: TabBarView(
          children: myTabs.map((Tab tab) {
            final String? label = tab.text?.toLowerCase();
            return Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await controller.initTmdbInstance();
                      var popular = await controller.tmdb.v3.tv.getPopular();
                      Logger.instance.i(popular);
                      Map l = await controller.tmdb.v3.movies.getLatest();
                      Logger.instance.i(l);
                    },
                    child: Text('tmdb'),
                  ),
                  Text(
                    'This is the $label tab',
                    style: const TextStyle(fontSize: 36),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<AggSearchController>();
    super.dispose();
  }
}
