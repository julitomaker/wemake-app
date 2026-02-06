/// Demo mode singleton - controls whether app runs with mock data
class DemoMode {
  static final DemoMode _instance = DemoMode._internal();
  factory DemoMode() => _instance;
  DemoMode._internal();

  bool _isDemo = false;

  bool get isActive => _isDemo;

  void activate() => _isDemo = true;
  void deactivate() => _isDemo = false;
}

final demoMode = DemoMode();
