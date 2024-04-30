import 'dart:convert';
import 'dart:developer';
import 'dart:html';

import 'package:frontend/data/app_portal.dart';
import 'package:flutter/widgets.dart';

import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import './config/app_config.dart';

import 'package:jwt_decoder/jwt_decoder.dart';

/// A mock authentication service
class AppPortalAuth extends ChangeNotifier {
  bool _signedIn = false;
  var _openid_tokens;

  Future<bool> getSignedIn() async {

    if (_signedIn)
      return _signedIn; // already signed in -- todo - remove before production release
    var tokens = window.localStorage['openid_client:tokens'];

    if (tokens != null) {
    
      _openid_tokens = json.decode(tokens);

      if (_openid_tokens != null && _openid_tokens['access_token'] != null) {
        _signedIn = true;
        _openid_tokens.forEach((key, value) =>
            print("Access token -- Key : $key, Value : $value"));
        Map<String, dynamic> decodedAccessToken =
            JwtDecoder.decode(_openid_tokens["access_token"]);
        decodedAccessToken.forEach((key, value) =>
            print("access_token -- Key : $key, Value : $value"));

        appPortalInstance.setJWTSub(decodedAccessToken["sub"]);
        appPortalInstance.setJWTEmail(decodedAccessToken["email"]);
        appPortalInstance.setDigitalId(decodedAccessToken["email"]);
        appPortalPersonMetaDataInstance
            .setScopes(decodedAccessToken["scope"] as String);

        bool isTokenExpired = JwtDecoder.isExpired(_openid_tokens["id_token"]);
        
        Map<String, dynamic> decodedIDToken =
            JwtDecoder.decode(_openid_tokens["id_token"]);
        decodedIDToken.forEach(
            (key, value) => print("id_token -- Key : $key, Value : $value"));
        print('email :: ' + decodedIDToken["email"]);

        if (isTokenExpired) {
          window.localStorage.remove('openid_client:tokens');
          window.localStorage.clear();
          _signedIn = false;
          return _signedIn;
        }

        bool isAccessTokenExpired =
            JwtDecoder.isExpired(_openid_tokens["access_token"]);
        print("Access token is expired $isAccessTokenExpired");
        if (AppConfig.apiTokens != null && isAccessTokenExpired) {
          // Use refresh token
          String refreshToken = AppConfig.refreshToken;
          String clientId = AppConfig.choreoSTSClientID;

          final response = await http.post(
            Uri.parse(AppConfig.asgardeoTokenEndpoint),
            headers: <String, String>{
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            encoding: Encoding.getByName('utf-8'),
            body: {
              'grant_type': 'refresh_token',
              'refresh_token': refreshToken,
              'client_id': clientId,
            },
          );

          if (response.statusCode == 200) {
            var refreshedTokens = json.decode(response.body);
            AppConfig.apiTokens = refreshedTokens;
            AppConfig.todoTaskBffApiKey = refreshedTokens["access_token"];
            AppConfig.refreshToken = refreshedTokens["refresh_token"];
            print('Access token refreshed successfully');
          } else {
            print('Failed to refresh access token');
            // Handle the error case appropriately
          }
        } else {
        
          int count = 0;
          while (AppConfig.choreoSTSClientID.isEmpty && count < 10) {
            count++;
            if (count > 10) {
              break;
            }
            await Future.delayed(Duration(seconds: 1));
          }
          final response = await http.post(
            Uri.parse(AppConfig.choreoSTSEndpoint),
            headers: <String, String>{
              //'Content-Type': 'application/x-www-form-urlencoded',
              //'Authorization': 'Bearer ${_openid_tokens["access_token"]}',
              //'Authorization': 'Bearer ' + AppConfig.admissionsApplicationBffApiKey,
            },
            encoding: Encoding.getByName('utf-8'),
            body: {
              "client_id": AppConfig.choreoSTSClientID,
              "subject_token_type": "urn:ietf:params:oauth:token-type:jwt",
              "grant_type": "urn:ietf:params:oauth:grant-type:token-exchange",
              "subject_token": _openid_tokens["access_token"],
            },
          );
          if (response.statusCode == 200) {
            var _api_tokens = json.decode(response.body);
            AppConfig.apiTokens = _api_tokens;
            _api_tokens
              ..forEach((key, value) =>
                  print("API tokens Key : $key, Value : $value"));
            AppConfig.todoTaskBffApiKey = _api_tokens["access_token"];
            AppConfig.refreshToken = _api_tokens["refresh_token"];
            print('Fetch API tokens success');
          } else {
            print('Failed to fetch API key');
            print('Fetch API tokens error :: ' + response.body.toString());
            print(response.statusCode);
            _signedIn = false;
          }
        }
      }
    } else {
      _signedIn = false;
      window.localStorage.clear();
    }

    if (_signedIn) {
      appPortalInstance.fetchPersonForUser();
    }

    return _signedIn;
  }

  Future<void> logout() async {
    String logoutUrl = AppConfig.asgardeoLogoutUrl;
    if (await canLaunchUrl(Uri.parse(logoutUrl))) {
      await launchUrl(Uri.parse(logoutUrl), mode: LaunchMode.platformDefault);
    } else {
      throw 'Could not launch $logoutUrl';
    }
    await Future.delayed(const Duration(seconds: 3));
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    // Sign out.
    window.localStorage.clear();
    _signedIn = false;
    try {
      await logout();
    } catch (error) {
      log(error.toString());
    }
    notifyListeners();
  }

  Future<bool> signIn(String username, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Sign in. Allow any password.
    _signedIn = true;
    notifyListeners();
    return _signedIn;
  }

  @override
  bool operator ==(Object other) =>
      other is AppPortalAuth && other._signedIn == _signedIn;

  @override
  int get hashCode => _signedIn.hashCode;
}

class SMSAuthScope extends InheritedNotifier<AppPortalAuth> {
  const SMSAuthScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static AppPortalAuth of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SMSAuthScope>()!.notifier!;
}
