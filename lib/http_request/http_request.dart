import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../common_methods/common_methods.dart';
import '../values/string_en.dart';

class HttpRequest {
  var connStatus = false;

  Future<dynamic> getRequest(
    String endPoint,
    String authToken, {
    String? param,
    BuildContext? context,
  }) async {
    // if (param != null) {
    //   url = url + '?' + param;
    // }
    // print('url--->$url');

    try {
      final response = await http.get(
        Uri.parse(endPoint),
        headers: {
          // 'Content-Type': 'application/json',
          // 'Accept': 'application/json',
          // 'Authorization': authToken,
        },
      );

      // checkConnectivity();

      if (context != null) {
        // await validateResponse(response, context);
      }

      if (response.statusCode == 200) {
        return response;
      }
    } catch (error) {
      // if (error.toString().contains('No route to host')) {
      //   showAuthErrorDialog('message', context!);
      // }
      rethrow;
    }
  }

  Future<dynamic> postRequest(String url, dynamic body, String authToken,
      {BuildContext? context}) async {
    var isGet = true;
    http.Response response;
    final fun = ((response) {
      validateResponse(response, context!);
    });
    if (context != null) {
      isGet = await connectivityStatus(context);
    }
    if (isGet) {
      if (!connStatus) {
        checkConnectivity(context!);
        connStatus = true;
      }
      // print(url);
      try {
        response = await http.post(
          Uri.parse(url),
          body: json.encode(body),
        );

        if (context != null) {
          fun(response);
        }

        if (response.statusCode == 200) {
          return response;
        }
        return response;
      } catch (error) {
        // print(error);
        rethrow;
      }
    } else {
      displaySnackbar(context: context!, msg: 'turn on mobile data or wifi');
    }
  }

  Future<bool> connectivityStatus(context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      if (kDebugMode) {
        print('connectedwith mobile');
      }
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      if (kDebugMode) {
        print('connectedwith wifi');
      }

      return true;
    } else {
      if (kDebugMode) {
        print('not connected with internet');
      }
    }
    return false;
  }

  checkConnectivity(context) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (kDebugMode) {
        print('internet connection-->');
      }
      // print(result);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (kDebugMode) {
          print('connected');
        }
      }
    } on SocketException catch (_) {
      connStatus = false;
      if (kDebugMode) {
        print('not connected');
      }
      await displaySnackbar(context: context, msg: 'not connected with server');
    }
  }

  Future? validateResponse(http.Response response, BuildContext context) {
    // print(response.statusCode);
    switch (response.statusCode) {
      // OK
      case 200:
        {
          if (kDebugMode) {
            print(200);
          }
          // return response;
        }
        break;
      //bad request
      case 400:
        {
          if (kDebugMode) {
            print(400);
          }
        }
        break;
      //Unauthorized
      case 401:
        {
          if (kDebugMode) {
            print(401);
          }

          return showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                      title: const Text(appTitleAuthenticationFail),
                      content: const Text(appTitleLoginAgain),
                      actions: [
                        TextButton(
                          child: const Text(appTitleOkay),
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/', (Route<dynamic> route) => false);
                          },
                        )
                      ]));
        }
      // break;
      //Not Found
      case 404:
        {
          if (kDebugMode) {
            print(404);
          }

          return showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                      title: const Text(appTitleSomethingWentWrong),
                      content:
                          const Text(appTitlePleaseContactSystemAdministrator),
                      actions: [
                        TextButton(
                          child: Text(
                            appTitleOkay,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/', (Route<dynamic> route) => false);
                          },
                        )
                      ]));
        }
      // break;

      default:
        {
          if (kDebugMode) {
            print('default');
            print(response.statusCode);
          }
        }
        break;
    }
    return null;
  }
}
