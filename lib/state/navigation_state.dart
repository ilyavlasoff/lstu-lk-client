import 'package:flutter/widgets.dart';

abstract class NavigationState {
  final int selectedIndex;
  NavigationState(this.selectedIndex);
}

class NavigatedToPersonalPage extends NavigationState {
  NavigatedToPersonalPage(index) : super(index);
}

class NavigatedToTimetablePage extends NavigationState {
  NavigatedToTimetablePage(index) : super(index);
}

class NavigatedToEducationPage extends NavigationState {
  NavigatedToEducationPage(index) : super(index);
}

class NavigatedToMessagesPage extends NavigationState {
  NavigatedToMessagesPage(index) : super(index);
}

class NavigatedToCustomPage extends NavigationState {
  final Widget customPage;
  NavigatedToCustomPage(index, this.customPage) : super(index);
}
