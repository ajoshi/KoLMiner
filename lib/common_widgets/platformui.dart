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
  // no need for button color- it's inherited from the theme now
  return ElevatedButton(onPressed: onPressed, child: child);
}
