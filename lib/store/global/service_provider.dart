import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:lk_client/service/amqp_service.dart';
import 'package:lk_client/service/api_consumer/achievement_query_service.dart';
import 'package:lk_client/service/api_consumer/discipline_query_service.dart';
import 'package:lk_client/service/api_consumer/education_query_service.dart';
import 'package:lk_client/service/api_consumer/file_transfer_service.dart';
import 'package:lk_client/service/api_consumer/messenger_query_service.dart';
import 'package:lk_client/service/api_consumer/person_query_service.dart';
import 'package:lk_client/service/api_consumer/util_query_service.dart';
import 'package:lk_client/service/config/amqp_config.dart';
import 'package:lk_client/service/config/app_config.dart';
import 'package:lk_client/service/authentication_extractor.dart';
import 'package:lk_client/service/api_consumer/authorization_service.dart';
import 'package:lk_client/service/file_local_manager.dart';
import 'package:lk_client/service/file_transfer_manager.dart';
import 'package:lk_client/service/jwt_manager.dart';
import 'package:lk_client/service/notification/notifier.dart';

class ServiceProvider {
  final JwtManager jwtManager;
  final AuthorizationService authorizationService;
  final AppConfig appConfig;
  final PersonQueryService personQueryService;
  final EducationQueryService educationQueryService;
  final AuthenticationExtractor authenticationExtractor;
  final DisciplineQueryService disciplineQueryService;
  final FileLocalManager fileLocalManager;
  final FileTransferManager fileTransferManager;
  final FileTransferService fileTransferService;
  final MessengerQueryService messengerQueryService;
  final AchievementQueryService achievementQueryService;
  final UtilQueryService utilQueryService;
  final FirebaseMessaging firebaseMessaging;
  final AmqpService amqpService;
  final Notifier notifier;
  final AmqpConfig amqpConfig;

  ServiceProvider(
      {@required this.jwtManager,
      @required this.authorizationService,
      @required this.appConfig,
      @required this.personQueryService,
      @required this.educationQueryService,
      @required this.firebaseMessaging,
      @required this.authenticationExtractor,
      @required this.disciplineQueryService,
      @required this.fileLocalManager,
      @required this.fileTransferManager,
      @required this.fileTransferService,
      @required this.achievementQueryService,
      @required this.utilQueryService,
      @required this.messengerQueryService,
      @required this.amqpConfig,
      @required this.notifier,
      @required this.amqpService});
}
