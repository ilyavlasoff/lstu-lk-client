import 'package:lk_client/bloc/attached/abstract_file_transfer_bloc.dart';
import 'package:lk_client/command/consume_command.dart';
import 'package:lk_client/service/api_consumer/file_transfer_service.dart';
import 'package:lk_client/service/app_config.dart';
import 'package:lk_client/service/file_local_manager.dart';
import 'package:lk_client/service/file_transfer_manager.dart';

class TeachingMaterialDocumentTransferBloc extends AbstractFileTransferBloc{
    TeachingMaterialDocumentTransferBloc(AppConfig config, FileLocalManager fileLocalManager, FileTransferService fileTransferService)
      : super(config, fileLocalManager, fileTransferService);

    @override
    Stream<FileOperationStatus> startUploadingOperation(MultipartRequestCommand command, String filePath) {
      return null;
    }

    @override
    Stream<FileOperationStatus> startDownloadingOperation(MultipartRequestCommand command, String filePath) {
      LoadTeachingMaterialAttachment _command = command as LoadTeachingMaterialAttachment;
      return this.transferService.downloadTeachingMaterialsAttachment(_command.teachingMaterial, filePath);
    }

}

class PrivateMessageSendDocumentTransferBloc extends AbstractFileTransferBloc {
  PrivateMessageSendDocumentTransferBloc(AppConfig config, FileLocalManager fileLocalManager, FileTransferService fileTransferService)
    : super(config, fileLocalManager, fileTransferService);

  @override
  Stream<FileOperationStatus> startDownloadingOperation(MultipartRequestCommand command, String filePath) {
    return null;
  }

  @override
  Stream<FileOperationStatus> startUploadingOperation(MultipartRequestCommand command, String filePath) {
    UploadPrivateMessageAttachment _command = command as UploadPrivateMessageAttachment;
    return this.transferService.uploadPrivateMessageAttachment(_command.message.id, filePath);
  }
}

class DiscussionMessageSendDocumentTransferBloc extends AbstractFileTransferBloc {
  DiscussionMessageSendDocumentTransferBloc(AppConfig config, FileLocalManager fileLocalManager, FileTransferService fileTransferService)
    : super(config, fileLocalManager, fileTransferService);

  @override
  Stream<FileOperationStatus> startDownloadingOperation(MultipartRequestCommand command, String filePath) {
    return null;
  }

  @override
  Stream<FileOperationStatus> startUploadingOperation(MultipartRequestCommand command, String filePath) {
    UploadPrivateMessageAttachment _command = command as UploadPrivateMessageAttachment;
    return this.transferService.uploadDiscussionMessageAttachment(_command.message.id, filePath);
  }
}