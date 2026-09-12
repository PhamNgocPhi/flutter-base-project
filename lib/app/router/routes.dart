/// Tên + path route tập trung một chỗ.
abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const settings = '/settings';
  static const example = '/example';
  static const logs = '/logs';

  /// Route vào được mà không cần đăng nhập.
  static const public = {splash, login};
}
