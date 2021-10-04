import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Returns an iosy button for ios, else androidy button
Widget getPlatformButton(BuildContext context,
    {required Widget child, Color? color, VoidCallback? onPressed}) {
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return CupertinoButton(
      onPressed: onPressed,
      child: child,
      color: color,
    );
  }
  // no need for button color- it's inherited from the theme now
  return ElevatedButton(onPressed: onPressed, child: child);
}

Widget getSecondaryButton(BuildContext context,
    {required Widget child, VoidCallback? onPressed}) {
  var style = ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed))
          return Theme.of(context).colorScheme.primary.withOpacity(0.5);
        return Colors.amberAccent; // Use the component's default.
      },
    ),
  );
  /*
    style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
  ),
   */

  return ElevatedButton(
    onPressed: onPressed,
    child: child,
    style: style,
  );
}

Widget getKolButton(BuildContext context,
    {required Widget child, VoidCallback? onPressed}) {
  var style = ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.black, width: 2.0))));

  return ElevatedButton(
    onPressed: onPressed,
    child: child,
    style: style,
  );
}
