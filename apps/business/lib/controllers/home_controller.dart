import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController instance = Get.find<HomeController>();

  final selectedIndex = 0.obs;
  Map<String, int> pathToIndex = {
    '/home': 0,
    '/shops': 1,
    '/campaigns': 2,
    '/rewards': 3,
    '/my-place': 4,
    '/top-token-holder': 5,
    '/news': 6,
  };

  Map<int, String> indexToPath = {};
  @override
  onInit() {
    indexToPath = Map.fromEntries(
        pathToIndex.entries.map((e) => MapEntry(e.value, e.key)));
    super.onInit();
  }

  void setSelectedIndex(String path) {
    if (path.startsWith('/campaign/')) {
      selectedIndex.value = 2;
    } else if (path.startsWith('/rewards/')) {
      selectedIndex.value = 3;
    } else if (path.startsWith('/news/')) {
      selectedIndex.value = 6;
    } else {
      selectedIndex.value =
          pathToIndex.containsKey(path) ? pathToIndex[path]! : 0;
    }
  }

  void navigateWithRail(int index) {
    index = indexToPath.containsKey(index) ? index : 0;
    Get.toNamed(indexToPath[index]!);
  }
}
