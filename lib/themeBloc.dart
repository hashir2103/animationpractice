import 'package:rxdart/rxdart.dart';

class ThemeBloc {
  final _darkTheme = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get darkTheme$ => _darkTheme.stream;
  Function(bool) get inDarkTheme => _darkTheme.sink.add;

  dispose() {
    _darkTheme.close();
  }
}
