import 'dart:convert';

import 'package:lk_client/model/person/person.dart';
import 'package:lk_client/model/person/personal_data.dart';
import 'package:lk_client/model/person/profile_picture.dart';
import 'package:lk_client/error_handler/component_error_handler.dart';
import 'package:lk_client/model/authentication/api_key.dart';
import 'package:lk_client/service/app_config.dart';
import 'package:lk_client/service/authentication_extractor.dart';
import 'package:lk_client/service/http_service.dart';

class PersonQueryService extends HttpService {
  final ComponentErrorHandler apiErrorHandler;
  final AuthenticationExtractor authenticationExtractor;

  ApiKey get accessKey => this.authenticationExtractor.getAuthenticationData();

  PersonQueryService(
      AppConfig config, this.authenticationExtractor, this.apiErrorHandler)
      : super(config);

  Stream<Person> getPersonProperties(String person) async* {
    HttpResponse response = await this.get('/api/v1/person/info',
        <String, String>{'p': person}, this.accessKey.token);

    if (response.status == 200) {
      Person person = Person.fromJson(response.body);
      yield person;
    } else {
      throw apiErrorHandler.apply(response.body);
    }

    response = await this.get('/api/v1/person/info',
        <String, String>{'p': '5:93535310'}, this.accessKey.token);

    if (response.status == 200) {
      Person person = Person.fromJson(response.body);
      yield person;
    }
  }

  Stream<Person> getCurrentPersonIdentifier() async* {
    HttpResponse response =
        await this.get('/api/v1/whoami', {}, this.accessKey.token);

    if (response.status == 200) {
      Person person = Person.fromJson(response.body);
      yield person;
    } else {
      throw apiErrorHandler.apply(response.body);
    }
  }

  Stream<ProfilePicture> getPersonProfilePicture(
      String person, String size) async* {
    HttpResponse response = await this.get('/api/v1/person/pic',
        <String, String>{'p': person, 'size': size}, this.accessKey.token);

    if (response.status == 200) {
      ProfilePicture pictureData = ProfilePicture.fromJson(response.body);
      yield pictureData;
    } else {
      throw apiErrorHandler.apply(response.body);
    }
  }

  Future<bool> editPersonProfile(PersonalData updatedProfileData) async {
    Map<String, dynamic> updateProfileSerialized = updatedProfileData.toJson();

    HttpResponse response = await this.post(
        '/api/v1/person/info', updateProfileSerialized, this.accessKey.token);

    if (response.status == 200) {
      return true;
    }

    throw this.apiErrorHandler.apply(response.body);
  }
}