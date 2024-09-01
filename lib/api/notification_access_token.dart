import 'dart:developer';

import 'package:googleapis_auth/auth_io.dart';

class NotificationAccessToken {
  static String? _token;

  //to generate token only once for an app run
  static Future<String?> get getToken async =>
      _token ?? await _getAccessToken();

  // to get admin bearer token
  static Future<String?> _getAccessToken() async {
    try {
      const fMessagingScope =
          'https://www.googleapis.com/auth/firebase.messaging';

      final client = await clientViaServiceAccount(
        // To get Admin Json File: Go to Firebase > Project Settings > Service Accounts
        // > Click on 'Generate new private key' Btn & Json file will be downloaded

        // Paste Your Generated Json File Content
        ServiceAccountCredentials.fromJson({
          "type": "service_account",
          "project_id": "mychat-6293d",
          "private_key_id": "75c1c92bc1ce5fb741506472f8c1d95e232f743f",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCMY/fk+RHKmfFd\nhEP1OU6LB+9sD2QrXcuzyix02xSWsCP4FH2Q6XfiMaqXGEHSucpHud6Tj/L61zzM\n2YEFVMOKQXwcd1zWHQt/BNnujAae+S597RZLRKXxFlg4lSGKOhPTxZLIRd6JxPj8\ndm3ANo+ln24xINTXJPtOPVqE6u7F8AIVmlobeGupwSaEs49AJMUXcD/8+37VRHfs\nETEJ0x25dTNfQlhZejV3BpmXJnwD8mfzQEmep2JNDigvUeEoGzl05cP45wXkvSlg\nIC1dGAUlRhPnMdOpVtgb95y3j44lK/hlTfx3cegPoU/1teRep2e8Wp4jBfEtw3uX\nqcybcpwJAgMBAAECggEABD77RsJ2NGqYw1duXz6xFpEiP4JNKSccc7b6BnxASIjy\nA40qGY2IHdAa/Ngj2IHcQXRYjB26z3WeTgNHjM/aHKa7oFhHV2X4PKqaxUVYp2r5\nqh8XMSZVvv+KIkb3ZVj5k8p6VKKRVxkdHzSdP+aejFews11u9oVUsPJ32ASLfXLI\nA3xFfRC2HetHz942WxJWPdoo66KMXFQ3Rtr7F58ofmfEexKLGUXs+QiR+l0B8fIE\nUbkAjRJo7oBeoVdDKS0nDA88ckg65aC1BoQGZi3PtZQPcLecV4YaBlktyz6o5mtO\nLxJGkNHPvVpwNPMHXCSmxFxj2mMgdc53dFFi5YJowQKBgQC/tk5NFXvHTty2BMb9\nhHZOS9+L3bpoe8l6ZPvgj3toyz1edsYUHzqPRdZwT8h6g00wVxsY8VmEMe9e8OwM\nrODp8FUJpFNvfXeKiaLiDDD3kg4ZoB9h0Z6pGBbdb0QybC4UvRqM+j0gt2klFoeT\n3EIgmUy63vpByczuq7y5/z+fSQKBgQC7d+mfXDQv59Q/yhJZrP9jH4c9eM+HaF8o\n+pg8NB1pNKNVxsHDAANVq3F6xIDi2cApAC6ly1JKac0H0vitoUWM62JP7+kEH0mK\nNX33lOAHTybcvwR9B4euD57suOgiB2ToqVo2aB8W2aAMV2CD/Mi0vSnatK/cJqw0\nYcBj0DFWwQKBgCa+tHJ1vg9Yy9hpfMHtzG8kfGhrBmppYh2/XPxUYy+Zq6x0urGE\nYjRke+M07KJ9+NKlOA/Bb0L9SJBahopFQitla/pH4KjupYM1L9sZdagDN6BMMSt2\nzucDvFNCUnkSTfnZAg2t4T7EcpaRSBNE94RZFx3JRLCZFTbDNKAuivApAoGAWPVn\nFCsRzKXLD1YZbRptuiDM8Tux5wR9G5oGwZLNXg4Pb/W4HouUCYQofmRe8Mb5q7sd\nZ6la7FrWY18WiHYd5egQp/Qlc8JRCFen5eNsh6tkup2eSKJZHRzmgligNv2hQdKT\nL3wrPJGapCCWeStsJnAZO2JAjUyArP6x5+t0bkECgYBF2qXIuca17XiUJfKuEY8T\n7u5EoLfU53OkIsFR0tpT93k5iBjuzLXT/UP1K88PuVFwMM8IaaYhbCESnyWD9V6p\nLogNLWZz71UXZKVQEA71SZEUI0lQuEuMg5MXAkRLdtC8+c1vs9rxg8fUTV3xJJci\nbO1AYYgMvNAvgev+fanTzg==\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-tnb1q@mychat-6293d.iam.gserviceaccount.com",
          "client_id": "105083369197574547725",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-tnb1q%40mychat-6293d.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        }),
        [fMessagingScope],
      );

      _token = client.credentials.accessToken.data;

      return _token;
    } catch (e) {
      log('$e');
      return null;
    }
  }
}
