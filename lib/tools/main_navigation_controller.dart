class MainNavigationController {
  MainNavigationController._();

  static final MainNavigationController instance = MainNavigationController._();

  void Function(int index)? _onSelectTab;

  void attach(void Function(int index) onSelectTab) => _onSelectTab = onSelectTab;

  void detach() => _onSelectTab = null;

  void openTab(int index) => _onSelectTab?.call(index);

  void openShop() => openTab(1);
}
