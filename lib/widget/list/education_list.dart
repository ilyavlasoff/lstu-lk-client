import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lk_client/bloc/loader_bloc.dart';
import 'package:lk_client/command/consume_command/education_request_command.dart';
import 'package:lk_client/event/consuming_event.dart';
import 'package:lk_client/model/education/education.dart';
import 'package:lk_client/model/person/person.dart';
import 'package:lk_client/service/api_consumer/education_query_service.dart';
import 'package:lk_client/state/consuming_state.dart';
import 'package:lk_client/store/global/app_state_container.dart';

class EducationList extends StatefulWidget {
  final Person _currentPerson;
  final Function _onSelectAction;

  EducationList(this._currentPerson, this._onSelectAction);

  @override
  _EducationListState createState() => _EducationListState();
}

class _EducationListState extends State<EducationList> {
  EducationListLoaderBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._bloc == null) {
      EducationQueryService queryService =
          AppStateContainer.of(context).serviceProvider.educationQueryService;
      this._bloc = EducationListLoaderBloc(queryService);
    }
  }

  @override
  dispose() async {
    Future.delayed(Duration.zero, () async {
      await this._bloc.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this._bloc.eventController.sink.add(
        StartConsumeEvent<LoadUserEducationListCommand>(
            request:LoadUserEducationListCommand(widget._currentPerson)));

    return StreamBuilder(
        stream: this._bloc.consumingStateStream,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data is ConsumingReadyState<List<Education>>) {
              List<Education> educationsList =
                  (snapshot.data as ConsumingReadyState<List<Education>>).content;

              return Container(
                  child: ListView.builder(
                      itemCount: educationsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            leading: FlutterLogo(
                              size: 50,
                            ),
                            title: Text(educationsList[index]
                                .group
                                .speciality
                                .specName),
                            subtitle: Text(educationsList[index]
                                .group
                                .speciality
                                .qualification),
                            onTap: () =>
                                widget._onSelectAction(educationsList[index]),
                          ),
                        );
                      }));
            }
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
