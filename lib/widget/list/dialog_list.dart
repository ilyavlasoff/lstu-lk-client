import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lk_client/bloc/infinite_scrollers/dialog_list_bloc.dart';
import 'package:lk_client/bloc/proxy/dialog_list_proxy_bloc.dart';
import 'package:lk_client/command/consume_command.dart';
import 'package:lk_client/event/endless_scrolling_event.dart';
import 'package:lk_client/model/messenger/dialog.dart' as DialogModel;
import 'package:lk_client/model/messenger/private_message.dart';
import 'package:lk_client/model/person/person.dart';
import 'package:lk_client/page/private_dialog_page.dart';
import 'package:lk_client/state/endless_scrolling_state.dart';
import 'package:lk_client/store/local/messenger_page_provider.dart';
import 'package:lk_client/widget/chunk/centered_loader.dart';
import 'package:lk_client/widget/chunk/list_loading_bottom_indicator.dart';
import 'package:lk_client/widget/layout/profile_picture.dart';
import 'package:lk_client/widget/list/endless_scrolling_widget.dart';

class DialogList extends StatefulWidget {
  final Person person;
  DialogList({Key key, @required this.person}) : super(key: key);

  @override
  _DialogListState createState() => _DialogListState();
}

class _DialogListState extends State<DialogList> {
  DialogListProxyBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._bloc == null) {
      this._bloc = MessengerPageProvider.of(context).dialogListBloc;
    }
  }

  @override
  Widget build(BuildContext context) {
    this._bloc.eventController.sink.add(
        EndlessScrollingLoadEvent<StartNotifyOnPerson>(
            command: StartNotifyOnPerson(trackedPerson: widget.person)));

    final ScrollController scrollController = ScrollController();

    bool needsAutoloading = false;

    return StreamBuilder(
      stream: this._bloc.dialogListStateStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data;

          if (state is EndlessScrollingInitState) {
            /**
             * Когда виджет инициализирован, на контроллер скролла вешается листенер
             * отправляющий новые команды для добавления строк
             * и отправляется команда
             */
            scrollController.addListener(() {
              final maxScroll = scrollController.position.maxScrollExtent;
              final currentScroll = scrollController.position.pixels;
              if (needsAutoloading && maxScroll - currentScroll <= 200) {
                this._bloc.eventController.sink.add(
                    EndlessScrollingLoadEvent<LoadDialogListCommand>(
                        command: LoadDialogListCommand(count: 50)));
              }
            });
            this._bloc.eventController.sink.add(
                EndlessScrollingLoadEvent<LoadDialogListCommand>(
                    command: LoadDialogListCommand(count: 50)));
          }

          if (state is EndlessScrollingChunkReadyState) {
            needsAutoloading = state.hasMoreData;
          } else {
            needsAutoloading = false;
          }

          if (state.entityList.length == 0) {
            if (state is EndlessScrollingLoadingState) {
              return CenteredLoader();
            }

            if (state is EndlessScrollingErrorState) {
              return Center(child: Text('Ошибка загрузки диалогов'));
            }

            return Center(child: Text('Ничего не найдено'));
          }

          List<DialogModel.Dialog> loadedDialogs = state.entityList;

          return ListView.builder(
              itemCount: ((state is EndlessScrollingChunkReadyState &&
                          state.hasMoreData) ||
                      state is EndlessScrollingLoadingState)
                  ? loadedDialogs.length + 1
                  : loadedDialogs.length,
              controller: scrollController,
              itemBuilder: (BuildContext context, int index) {
                if (index >= loadedDialogs.length) {
                  return ListLoadingBottomIndicator();
                }

                Person companion = loadedDialogs[index].companion;
                PrivateMessage lastDialogMessage =
                    loadedDialogs[index].lastMessage;
                String displayedMessageText =
                    lastDialogMessage?.messageText ?? '';

                return Container(
                  child: ListTile(
                    leading:
                        PersonProfilePicture(displayed: companion, size: 27.0),
                    title: Text("${companion.name} ${companion.surname}"),
                    subtitle: Text("$displayedMessageText"),
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return PrivateDialogPage(
                            companion: companion, dialog: loadedDialogs[index]);
                      }));
                    },
                  ),
                );
              });
        }

        return CenteredLoader();
      },
    );
  }
}
