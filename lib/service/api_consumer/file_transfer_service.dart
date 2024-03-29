import 'package:lk_client/model/authentication/api_key.dart';
import 'package:lk_client/service/authentication_extractor.dart';
import 'package:lk_client/service/file_transfer_manager.dart';

class FileTransferService {
  final FileTransferManager fileTransferManager;
  final AuthenticationExtractor authenticationExtractor;

  FileTransferService(this.fileTransferManager, this.authenticationExtractor);

  Stream<FileOperationStatus> downloadTeachingMaterialsAttachment(
      String teachingMaterialId, String filePath) async* {
    yield* this.fileTransferManager.progressedDownload(
        '/api/v1/materials/doc',
        <String, String>{'material': teachingMaterialId},
        await this.authenticationExtractor.getAuthenticationData,
        filePath);
  }

  Stream<FileOperationStatus> downloadStudentTaskAnswerMaterialAttachment(
      String answerAttachmentId, String filePath) async* {
    String apiToken = await this.authenticationExtractor.getAuthenticationData;
    yield* this.fileTransferManager.progressedDownload(
        '/api/v1/student/tasks/doc',
        <String, String>{'answer': answerAttachmentId},
        apiToken,
        filePath);
  }

  Stream<FileOperationStatus> downloadDiscussionMessageMaterialAttachment(
      String discussionMessageId, String filePath) async* {
    String apiToken = await this.authenticationExtractor.getAuthenticationData;
    yield* this.fileTransferManager.progressedDownload('/api/v1/discussion/doc',
        <String, String>{'msg': discussionMessageId}, apiToken, filePath);
  }

  Stream<FileOperationStatus> downloadPrivateMessageMaterialsAttachment(
      String privateMessageId, String filePath) async* {
    String apiToken = await this.authenticationExtractor.getAuthenticationData;
    yield* this.fileTransferManager.progressedDownload('/api/v1/messenger/doc',
        {'pmsg': privateMessageId}, apiToken, filePath);
  }

  Stream<FileOperationStatus> uploadPrivateMessageAttachment(
      String privateMessageId, String filePath) async* {
    yield* this.fileTransferManager.progressedUpload(
        '/api/v1/messenger/doc',
        <String, String>{'pmsg': privateMessageId},
        await this.authenticationExtractor.getAuthenticationData,
        filePath);
  }

  Stream<FileOperationStatus> uploadDiscussionMessageAttachment(
      String discussionMessageId, String filePath) async* {
    yield* this.fileTransferManager.progressedUpload(
        '/api/v1/discussion/doc',
        {'msg': discussionMessageId},
        await this.authenticationExtractor.getAuthenticationData,
        filePath);
  }

  Stream<FileOperationStatus> uploadWorkAnswerAttachment(
      String workAnswerAttachmentId, String filePath) async* {
    String apiToken = await this.authenticationExtractor.getAuthenticationData;
    yield* this.fileTransferManager.progressedUpload(
        '/api/v1/student/tasks/doc',
        {'answer': workAnswerAttachmentId},
        apiToken,
        filePath);
  }
}
