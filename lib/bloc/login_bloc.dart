import 'dart:async';

import 'package:lk_client/bloc/authentication_bloc.dart';
import 'package:lk_client/event/authentication_event.dart';
import 'package:lk_client/event/login_event.dart';
import 'package:lk_client/model/response/business_logic_error.dart';
import 'package:lk_client/model/response/jwt_token.dart';
import 'package:lk_client/service/http/authorization_service.dart';
import 'package:lk_client/state/login_state.dart';

class LoginBloc
{
  LoginState _currentLoginState;
  AuthorizationService _authorizationService;
  AuthenticationBloc _authenticationBloc;

  StreamController<LoginState> _stateController = StreamController<LoginState>();
  Stream<LoginState> get state => _stateController.stream;

  StreamController<LoginEvent> eventController = StreamController<LoginEvent>();
  Stream<LoginEvent> get _event => eventController.stream;

  void _updateState(LoginState newState) {
    this._currentLoginState = newState;
    this._stateController.add(newState);
  }

  LoginBloc({AuthorizationService authorizationService, AuthenticationBloc authenticationBloc}) {
    this._authorizationService = authorizationService;
    this._authenticationBloc = authenticationBloc;
    this._currentLoginState = LoginInitState();

    this._event.listen((LoginEvent event) async {
      if (event is LoginButtonPressedEvent) {
        this._updateState(LoginProcessingState());
        try {
          JwtToken token = await this._authorizationService.authenticate(event.userLoginCredentials);
          this._authenticationBloc.eventController.add(LoggedInEvent(apiToken: token));
          this._updateState(LoginInitState());
        } on BusinessLogicError catch(ble) {
          this._updateState(LoginErrorState(error: ble));
        } 
        on Exception {
          this._updateState(LoginErrorState(error: new BusinessLogicError(
            code: 'UNDEFINED_ERROR',
            systemMessage: 'UNDEFINED_ERROR',
            userMessage: 'An unexpected error occured',
            errorProperties: {}
          )));
        }
      }
    });
  }
}