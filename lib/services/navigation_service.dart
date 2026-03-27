class NavigationService {
  static final NavigationService _instance = NavigationService._internal();

  late Function(int) _onNavigate;

  factory NavigationService() {
    return _instance;
  }

  NavigationService._internal();

  void setNavigationCallback(Function(int) callback) {
    _onNavigate = callback;
  }

  void navigateTo(int index) {
    _onNavigate(index);
  }
}
