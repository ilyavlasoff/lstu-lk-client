import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lk_client/bloc/subject_list_bloc.dart';
import 'package:lk_client/command/consume_command/education_request_command.dart';
import 'package:lk_client/event/consuming_event.dart';
import 'package:lk_client/model/education/education.dart';
import 'package:lk_client/model/education/semester.dart';
import 'package:lk_client/model/discipline/discipline.dart';
import 'package:lk_client/service/api_consumer/education_query_service.dart';
import 'package:lk_client/store/global/app_state_container.dart';
import 'package:lk_client/widget/chunk/list_widget.dart';

class DisciplineList extends StatefulWidget 
{
  final Semester semester;
  final Education education;
  final Function onItemTap;

  DisciplineList({Key key, @required this.education, @required this.semester, this.onItemTap}): super(key: key);

  @override
  _DisciplineListState createState() => _DisciplineListState();
}

class _DisciplineListState extends State<DisciplineList> 
{
  SubjectListBloc _subjectListBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_subjectListBloc == null) {
      EducationQueryService queryService =
          AppStateContainer.of(context).serviceProvider.educationQueryService;
      this._subjectListBloc = SubjectListBloc(queryService);
    }
  }

  @override
  Widget build(BuildContext context) {
    this._subjectListBloc.eventController.sink.add(
        StartConsumeEvent<LoadSubjectListCommand>(
            request: LoadSubjectListCommand(widget.education, widget.semester)));

    return ListWidget(
      loadingStream: this._subjectListBloc.subjectListContentStateStream,
      listBuilder: (List<Discipline> argumentList) {
        return ListView.builder(
          itemCount: argumentList.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: ListTile(
                leading: FlutterLogo(size: 36.0),
                title: Text(argumentList[index].name),
                onTap: widget.onItemTap(argumentList[index])
              ),
            );
          }
        );
      },
    );
  }
}