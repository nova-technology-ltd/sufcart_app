import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:sufcart_app/utilities/components/show_snack_bar.dart';

void httpErrorHandler({required http.Response response, required BuildContext context, required VoidCallback onSuccess}) {
  switch (response.statusCode) {
    case 200:
    // showSnackBar(context: context, message: jsonDecode(response.body)['message']);
      onSuccess();
      break;
    case 201:
      onSuccess();
      break;
    case 400:
      showSnackBar(context: context, message: jsonDecode(response.body)['message'], title: jsonDecode(response.body)['title']);
      break;
    case 401:
      showSnackBar(context: context, message: jsonDecode(response.body)['message'], title: jsonDecode(response.body)['title']);
      break;
    case 500:
      showSnackBar(context: context, message: jsonDecode(response.body)['message'], title: jsonDecode(response.body)['title']);
      break;
    case 404:
      showSnackBar(context: context, message: jsonDecode(response.body)['message'], title: jsonDecode(response.body)['title']);
      break;
    case 203:
      showSnackBar(context: context, message: jsonDecode(response.body)['message'], title: jsonDecode(response.body)['title']);
      break;
    default:
      showSnackBar(context: context, message: jsonDecode(response.body)['message'], title: jsonDecode(response.body)['title']);
      break;
  }
}