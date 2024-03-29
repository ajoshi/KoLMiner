// Mocks generated by Mockito 5.0.16 from annotations
// in kol_miner/test/chat_commands/chat_command_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i3;

import 'package:kol_miner/network/kol_network.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeNetworkResponse_0 extends _i1.Fake implements _i2.NetworkResponse {}

/// A class which mocks [KolNetwork].
///
/// See the documentation for Mockito's code generation for more information.
class MockKolNetwork extends _i1.Mock implements _i2.KolNetwork {
  MockKolNetwork() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get appName =>
      (super.noSuchMethod(Invocation.getter(#appName), returnValue: '')
          as String);
  @override
  bool isLoggedIn() => (super.noSuchMethod(Invocation.method(#isLoggedIn, []),
      returnValue: false) as bool);
  @override
  _i3.Future<_i2.NetworkResponseCode> login(
          String? username, String? password) =>
      (super.noSuchMethod(Invocation.method(#login, [username, password]),
              returnValue: Future<_i2.NetworkResponseCode>.value(
                  _i2.NetworkResponseCode.SUCCESS))
          as _i3.Future<_i2.NetworkResponseCode>);
  @override
  String getPlayerId() =>
      (super.noSuchMethod(Invocation.method(#getPlayerId, []), returnValue: '')
          as String);
  @override
  _i3.Future<Map<dynamic, dynamic>?> getPlayerData() =>
      (super.noSuchMethod(Invocation.method(#getPlayerData, []),
              returnValue: Future<Map<dynamic, dynamic>?>.value())
          as _i3.Future<Map<dynamic, dynamic>?>);
  @override
  void logout() => super.noSuchMethod(Invocation.method(#logout, []),
      returnValueForMissingStub: null);
  @override
  _i3.Future<_i2.NetworkResponse> makeRequestWithQueryParams(
          String? baseUrl, String? params,
          {_i2.HttpMethod? method = _i2.HttpMethod.GET,
          _i2.NetworkResponse? emptyResponseDefaultValue}) =>
      (super.noSuchMethod(
              Invocation.method(#makeRequestWithQueryParams, [
                baseUrl,
                params
              ], {
                #method: method,
                #emptyResponseDefaultValue: emptyResponseDefaultValue
              }),
              returnValue:
                  Future<_i2.NetworkResponse>.value(_FakeNetworkResponse_0()))
          as _i3.Future<_i2.NetworkResponse>);
  @override
  _i3.Future<_i2.NetworkResponse> makeRequestToPath(String? urlWithParams,
          {_i2.HttpMethod? method = _i2.HttpMethod.GET,
          _i2.NetworkResponse? emptyResponseDefaultValue}) =>
      (super.noSuchMethod(
              Invocation.method(#makeRequestToPath, [
                urlWithParams
              ], {
                #method: method,
                #emptyResponseDefaultValue: emptyResponseDefaultValue
              }),
              returnValue:
                  Future<_i2.NetworkResponse>.value(_FakeNetworkResponse_0()))
          as _i3.Future<_i2.NetworkResponse>);
  @override
  _i3.Future<_i2.NetworkResponse> makeRequest(String? url,
          {_i2.HttpMethod? method = _i2.HttpMethod.GET,
          _i2.NetworkResponse? emptyResponseDefaultValue}) =>
      (super.noSuchMethod(
              Invocation.method(#makeRequest, [
                url
              ], {
                #method: method,
                #emptyResponseDefaultValue: emptyResponseDefaultValue
              }),
              returnValue:
                  Future<_i2.NetworkResponse>.value(_FakeNetworkResponse_0()))
          as _i3.Future<_i2.NetworkResponse>);
  @override
  String toString() => super.toString();
}
