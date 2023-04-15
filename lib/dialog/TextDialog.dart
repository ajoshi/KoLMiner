import 'dart:math';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';

/// stolen from https://api.flutter.dev/flutter/material/showDialog.html
Future<void> textDialog(BuildContext context, String title, String message,
    {String? okButtonText}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.subtitle1,
            ),
            child: Text(_getOkButtonText(okButtonText)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/// yolo
String _getOkButtonText(String? okButtonText) {
  if (okButtonText != null) {
    return okButtonText;
  }
  var rand = Random().nextInt(6);

  switch (rand) {
    case 0:
      return "Cool";
    case 1:
      return "Aight";
    case 2:
      return "10-4";
    case 3:
      return "Gotcha";
    case 4:
      return "Yeah";
    case 5:
      return "Awesome";
    default:
      return "yes";
  }
}
