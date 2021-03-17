import 'package:flutter/material.dart';
import 'bloc_container.dart';

class AppStateContainer extends StatefulWidget {
  final Widget child;
  final BlocContainer blocLibrary;

  AppStateContainer({Key key, @required this.child, @required this.blocLibrary})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => AppState();

  static AppState of(BuildContext context) {
    AppStateContainerInherited inherited = context
        .dependOnInheritedWidgetOfExactType<AppStateContainerInherited>();
    return inherited.appState;
  }
}

class AppStateContainerInherited extends InheritedWidget {
  final AppState appState;

  AppStateContainerInherited(
      {Key key, @required this.appState, @required child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(AppStateContainerInherited old) => true;
}

class AppState extends State<AppStateContainer> {
  BlocContainer get blocLibrary => widget.blocLibrary;

  // global defined values here
  // bloc container access by AppStateContainer.of(context).blockContainer

  @override
  Widget build(BuildContext context) {
    return AppStateContainerInherited(
      appState: this,
      child: widget.child,
    );
  }
}
