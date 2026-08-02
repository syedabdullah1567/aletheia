import 'package:hive/hive.dart';

class DarkmodeDatabase {
  bool isDark = false;

  final _myBox = Hive.box('MyBox');

  void loadIsDark() {
    isDark = _myBox.get('ISDARK');
  }

  void updateIsDark() {
    _myBox.put('ISDARK', isDark);
  }
}
