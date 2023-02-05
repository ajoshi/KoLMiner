import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../constants.dart';

/// Returns an iosy button for ios, else androidy button
Widget getPlatformButton(BuildContext context,
    {required Widget child, Color? color, VoidCallback? onPressed}) {
  if (USE_NEUMORPHISM) {
    return NeumorphicButton(
      onPressed: onPressed,
      child: child,
    );
  }

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

/// Returns an iosy button for ios, else androidy button
Widget neumorphicButton(BuildContext context,
    {required Widget child, Color? color, VoidCallback? onPressed}) {
  return NeumorphicButton(
    onPressed: onPressed,
    child: child,
  );
}

/// Returns a KOL style checkbox
Widget getCheckbox(BuildContext context,
    {ValueChanged<bool?>? onchanged, bool? initialValue, Color? color}) {
  return new Checkbox(
    value: initialValue,
    fillColor: MaterialStateProperty.resolveWith((states) {
      ///  * [MaterialState.selected].
      ///  * [MaterialState.hovered].
      ///  * [MaterialState.focused].
      ///  * [MaterialState.disabled].
      if (states.contains(MaterialState.selected)) {
        return Colors.indigo;
      }
    }),
    onChanged: onchanged,
  );
}

Widget getSecondaryButton(BuildContext context,
    {required Widget child, VoidCallback? onPressed}) {
  var style = ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed))
          return Theme.of(context).colorScheme.secondary.withOpacity(0.5);
        return Colors.amberAccent; // Use the component's default.
      },
    ),
  );

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

Widget raisedBorder({required Widget child, double depth = 2, double width = 2, double extraPadding = 0}) {
  return Neumorphic(
      style: NeumorphicStyle(
        // shape: NeumorphicShape.concave,
        depth: depth,
      ),
      child: new Padding(
          padding: EdgeInsets.all(width),
          child: Neumorphic(
            child: Padding(child: child, padding: EdgeInsets.all(extraPadding)),
            style: NeumorphicStyle(
              // shape: NeumorphicShape.concave,
              depth: -1*depth,
            ),
          )));
}
