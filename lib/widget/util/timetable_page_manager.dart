import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lk_client/bloc/timetable_page_manager_bloc.dart';
import 'package:lk_client/event/timetable_section_event.dart';
import 'package:lk_client/model/education/education.dart';
import 'package:lk_client/model/education/semester.dart';
import 'package:lk_client/model/person/person.dart';
import 'package:lk_client/page/basic/fullscreen_loading_page.dart';
import 'package:lk_client/page/timetable_page.dart';
import 'package:lk_client/state/timetable_section_state.dart';
import 'package:lk_client/store/local/timetable_page_provider.dart';
import 'package:lk_client/widget/list/education_list.dart';
import 'package:lk_client/widget/list/semester_list.dart';
import 'package:lk_client/widget/util/bottom_navigator.dart';

class TimetablePageManager extends StatefulWidget {
  final Person currentPerson;

  TimetablePageManager(this.currentPerson);

  @override
  _TimetablePageManagerState createState() => _TimetablePageManagerState();
}

class _TimetablePageManagerState extends State<TimetablePageManager> {
  TimetablePageManagerBloc _timetablePageManagerBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._timetablePageManagerBloc == null) {
      this._timetablePageManagerBloc =
          TimetablePageProvider.of(context).timetablePageManagerBloc;
    }
  }

  @override
  Widget build(BuildContext context) {
    this
        ._timetablePageManagerBloc
        .eventController
        .sink
        .add(TimetableLoadingMethodAutoSelect(person: widget.currentPerson));

    return StreamBuilder(
      stream: this._timetablePageManagerBloc.timetableSectionStateStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data is TimetableSectionState) {
          if (snapshot.data is TimetableReadyState) {
            return this.getTimetablePage(snapshot.data);
          }

          if (snapshot.data is WaitForEducationData) {
            final person =
                (snapshot.data as WaitForEducationData).currentPerson;
            return this.getEducationListPage(person);
          }

          if (snapshot.data is WaitForSemesterData) {
            final education = (snapshot.data as WaitForSemesterData).education;
            return this.getSemesterListPage(education);
          }

          if (snapshot.data is TimetableDefaultSelectionError) {
            return this.getErrorLoadingPage();
          }
        }

        return FullscreenLoadingPage();
      },
    );
  }

  Widget getTimetablePage(TimetableReadyState currentState) {
    List<Widget> timetableOptions = <Widget>[];
    if (currentState is SelectedTimetableByDefault) {
      timetableOptions.add(GestureDetector(
        onTap: () {
          this
              ._timetablePageManagerBloc
              .eventController
              .add(ForceCustomTimetableSelection(person: widget.currentPerson));
        },
        child: Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.calendar_today_rounded, size: 24.0)),
      ));
    } else if (currentState is SelectedCustomTimetable &&
        currentState.allowSwitchToDefault) {
      timetableOptions.addAll([
        GestureDetector(
          onTap: () {
            this._timetablePageManagerBloc.eventController.add(
                ForceDefaultTimetableSelection(person: widget.currentPerson));
          },
          child: Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.favorite_border_rounded, size: 24.0)),
        ),
        GestureDetector(
          onTap: () {
            this._timetablePageManagerBloc.eventController.add(
                ForceCustomTimetableSelection(person: widget.currentPerson));
          },
          child: Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(Icons.calendar_today_rounded, size: 24.0)),
        )
      ]);
    }

    return Scaffold(
      body: TimetablePage(
        education: currentState.education,
        semester: currentState.semester,
        timetableSelectorList: timetableOptions,
      ),
      bottomNavigationBar: BottomNavigator(),
    );
  }

  Widget getEducationListPage(Person person) {
    return Scaffold(
      appBar: AppBar(title: Text('Период обучения')),
      body: EducationList(person, (Education edu) {
        this
            ._timetablePageManagerBloc
            .eventController
            .sink
            .add(ProvideEducationData(education: edu));
      }),
      bottomNavigationBar: BottomNavigator(),
    );
  }

  Widget getSemesterListPage(Education education) {
    return Scaffold(
      appBar: AppBar(title: Text('Учебный семестр')),
      body: SemesterList(education, (Semester semester) {
        this
            ._timetablePageManagerBloc
            .eventController
            .sink
            .add(ProvideSemesterData(education: education, semester: semester));
      }),
      bottomNavigationBar: BottomNavigator(),
    );
  }

  Widget getErrorLoadingPage() {
    return Scaffold(
      appBar: AppBar(title: Text('Расписание')),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Невозможно определить текущий семестр'),
        ElevatedButton(
            child: Text('Указать вручную'),
            onPressed: () {
              this._timetablePageManagerBloc.eventController.sink.add(
                  ForceCustomTimetableSelection(
                      person: widget.currentPerson,
                      allowSwitchToDefault: false));
            })
      ])),
    );
  }
}
