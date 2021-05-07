import 'package:lk_client/model/education/education.dart';
import 'package:lk_client/model/education/semester.dart';
import 'package:lk_client/model/discipline/discipline.dart';
import 'package:lk_client/error_handler/component_error_handler.dart';
import 'package:lk_client/model/authentication/api_key.dart';
import 'package:lk_client/model/listed_response.dart';
import 'package:lk_client/service/app_config.dart';
import 'package:lk_client/service/authentication_extractor.dart';
import 'package:lk_client/service/http_service.dart';
import 'package:lk_client/state/consuming_state.dart';

class EducationQueryService extends HttpService {
  final ComponentErrorHandler apiErrorHandler;
  final AuthenticationExtractor authenticationExtractor;

  ApiKey get accessKey => authenticationExtractor.getAuthenticationData();

  EducationQueryService(AppConfig configurator, this.authenticationExtractor,
      this.apiErrorHandler)
      : super(configurator);

  Stream<ConsumingState<ListedResponse<Education>>> getEducationsList(
      String person) async* {
    try {
      HttpResponse response = await this.get('/api/v1/student/edu/list',
          <String, String>{'p': person}, this.accessKey.token);

      if (response.status == 200) {
        ListedResponse<Education> personEducationsList =
            ListedResponse.fromJson(response.body, Education.fromJson);
        yield ConsumingReadyState<ListedResponse<Education>>(
            personEducationsList);
      } else {
        throw this.apiErrorHandler.apply(response.body);
      }
    } on Exception catch (e) {
      yield ConsumingErrorState<ListedResponse<Education>>(error: e);
    }
  }

  Stream<ConsumingState<ListedResponse<Semester>>> getSemesterList(
      String educationId) async* {
    try {
      HttpResponse response = await this.get('/api/v1/student/edu/semesters',
          <String, String>{'edu': educationId}, this.accessKey.token);

      if (response.status == 200) {
        ListedResponse<Semester> personSemesterList =
            ListedResponse.fromJson(response.body, Semester.fromJson);
        yield ConsumingReadyState<ListedResponse<Semester>>(personSemesterList);
      } else {
        throw this.apiErrorHandler.apply(response.body);
      }
    } on Exception catch (e) {
      yield ConsumingErrorState<ListedResponse<Semester>>(error: e);
    }
  }

  Stream<ConsumingState<ListedResponse<Discipline>>> getSubjectList(
      String educationId, String semesterId) async* {
    try {
      HttpResponse response = await this.get(
          '/api/v1/student/discipline/list',
          <String, String>{'edu': educationId, 'sem': semesterId},
          this.accessKey.token);

      if (response.status == 200) {
        ListedResponse<Discipline> requiredDisciplineList =
            ListedResponse.fromJson(response.body, Discipline.fromJson);
        yield ConsumingReadyState<ListedResponse<Discipline>>(
            requiredDisciplineList);
      } else {
        throw this.apiErrorHandler.apply(response.body);
      }
    } on Exception catch (e) {
      yield ConsumingErrorState<ListedResponse<Discipline>>(error: e);
    }
  }

  Stream<ConsumingState<Semester>> getCurrentSemester(
      String educationId) async* {
    try {
      HttpResponse response = await this.get(
          '/api/v1/student/edu/semesters/current',
          <String, String>{'edu': educationId},
          this.accessKey.token);

      if (response.status == 200) {
        Semester currentSemester = Semester.fromJson(response.body);
        yield ConsumingReadyState<Semester>(currentSemester);
      } else {
        throw this.apiErrorHandler.apply(response.body);
      }
    } on Exception catch (e) {
      yield ConsumingErrorState<Semester>(error: e);
    }
  }
}
