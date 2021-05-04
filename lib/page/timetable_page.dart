import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lk_client/model/education/education.dart';
import 'package:lk_client/model/education/semester.dart';
import 'package:lk_client/model/person/person.dart';

class TimetablePage extends StatefulWidget {
  final Education education;
  final Semester semester;
  final Widget timetableSelector;

  TimetablePage(
      {Key key,
      @required this.education,
      @required this.semester,
      this.timetableSelector})
      : super(key: key);

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    this._tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Расписание'),
        actions: [widget.timetableSelector],
        bottom: TabBar(
          controller: this._tabController,
          tabs: [
            Tab(icon: Icon(Icons.directions_car)),
            Tab(icon: Icon(Icons.gesture_rounded)),
            Tab(icon: Icon(Icons.access_alarm_outlined)),
          ],
        ),
      ),
      body: Center(child: Text('This is a timetable page')),
    );
  }
}
