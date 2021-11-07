import 'package:flutter/material.dart';

class SafeTextEditingController extends TextEditingController {


  SafeTextEditingController register(SafeTextEditingControllerHost host) {
    host.getTextEditingControllers().add(this);
    return this;
  }
}

abstract class SafeTextEditingControllerHost<T extends StatefulWidget>
    extends State<T> {
  List<TextEditingController> allTextEditingControllers =
      List.empty(growable: true);

  List<TextEditingController> getTextEditingControllers() {
    return allTextEditingControllers;
  }

  @override
  void dispose() {
    unregisterAllTextEditingControllers();
    super.dispose();
  }

  void unregisterAllTextEditingControllers() {
    var allControllers = getTextEditingControllers();
    allControllers.forEach((controller) {
      controller.dispose();
    });
  }
}
