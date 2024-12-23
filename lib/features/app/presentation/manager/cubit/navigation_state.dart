abstract class NavigationState {
  final int index;
  const NavigationState(this.index);
}

class NavigationInitial extends NavigationState {
  const NavigationInitial() : super(0);
}

class NavigationUpdated extends NavigationState {
  const NavigationUpdated(int index) : super(index);
}
