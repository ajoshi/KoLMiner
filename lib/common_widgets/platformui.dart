import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Returns an iosy button for ios, else androidy button
Widget getPlatformButton(BuildContext context, {required Widget child, Color? color , VoidCallback? onPressed}) {
  if(Theme.of(context).platform == TargetPlatform.iOS) {
    return CupertinoButton(
      onPressed: onPressed,
      child: child,
      color: color,
    );
  }
  return RaisedButton(
    onPressed: onPressed,
    child: child,
    color: color,
    disabledColor: color == null? null :color.withAlpha(200),
  );
}
