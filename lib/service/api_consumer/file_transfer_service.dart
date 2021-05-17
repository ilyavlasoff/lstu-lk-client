import 'package:lk_client/model/authentication/api_key.dart';
import 'package:lk_client/service/authentication_extractor.dart';
import 'package:lk_client/service/file_transfer_manager.dart';

class FileTransferService {
  final FileTransferManager fileTransferManager;
  final AuthenticationExtractor authenticationExtractor;

  FileTransferService(this.fileTransferManager, this.authenticationExtractor);

  ApiKey get accessKey => this.authenticationExtractor.getAuthenticationData();

  Stream<FileOperationStatus> downloadTeachingMaterialsAttachment(
      String teachingMaterialId, String filePath) async* {
    yield* this.fileTransferManager.progressedDownload(
        '/api/v1/materials/doc', <String, String>{'material': teachingMaterialId}, this.accessKey.token, filePath);
  }

  Stream<FileOperationStatus> uploadPrivateMessageAttachment(
    String privateMessageId, String filePath) async* {
    yield* this.fileTransferManager.progressedUpload
      ('/api/v1/messenger/doc', <String, String>{'pmsg': privateMessageId}, this.accessKey.token, filePath);
  }

  Stream<FileOperationStatus> uploadDiscussionMessageAttachment(String discussionMessageId, String filePath) async* {
    yield* this.fileTransferManager.progressedUpload
      ('/api/v1/discussion/doc', {'msg': discussionMessageId}, this.accessKey.toString(), filePath);
  }
}
