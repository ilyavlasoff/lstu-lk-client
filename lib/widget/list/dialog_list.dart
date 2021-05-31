import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lk_client/bloc/infinite_scrollers/dialog_list_bloc.dart';
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
  DialogListBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this._bloc == null) {
      this._bloc = MessengerPageProvider.of(context).dialogListBloc;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Инициализация заполнения списка
    final loadingCommand = EndlessScrollingLoadEvent<LoadDialogListCommand>(
        command:
            LoadDialogListCommand(count: 50, offset: 0, person: widget.person));

    this._bloc.eventController.sink.add(loadingCommand);

    final ScrollController scrollController = ScrollController();
    final int scrollDistance = 200;

    bool needsAutoloading = false;

    scrollController.addListener(() {
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.position.pixels;
      if (needsAutoloading && maxScroll - currentScroll <= scrollDistance) {
        this._bloc.eventController.sink.add(loadingCommand);
      }
    });

    return EndlessScrollingWidget<DialogModel.Dialog, LoadDialogListCommand>(
      bloc: this._bloc,
      buildList: (EndlessScrollingState<DialogModel.Dialog> state) {
        if (state is EndlessScrollingChunkReadyState) {
          needsAutoloading =
              (state as EndlessScrollingChunkReadyState).hasMoreData;
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
                        (state as EndlessScrollingChunkReadyState)
                            .hasMoreData) ||
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
      },
    );
  }
}
