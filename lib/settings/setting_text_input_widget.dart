import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kol_miner/utils.dart';

/// Edittext that lets users enter savable settings
class SettingTextInputField extends StatelessWidget {
  SettingTextInputField(
    this.hintText,
    this.inputType,
    this.changeListener,
    this.textEditingController
  );

  final String hintText;
  final TextInputType inputType;
  final ValueChanged<String> changeListener;

  final TextEditingController textEditingController;

  Widget _buildInputWidget(String hintText, TextInputType inputType,
      ValueChanged<String> changeListener) {
    return Flexible(
              child: Container(
            margin: const EdgeInsets.all(6.0),
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: Colors.black, // set border color
                  width: 0.8),
              borderRadius: BorderRadius.all(Radius.zero),
            ),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    // if(!hasFocus) {
                    var text = textEditingController.value.text;
                    changeListener.call(text);
                    aj_print(text);
                    // }
                  },
            child: new TextField(
              decoration: new InputDecoration.collapsed(
                hintText: hintText,
              ),
              enabled: true,
              keyboardType: inputType,
            ),
          ),
      ),

    );
  }

  @override
  Widget build(BuildContext context) {
    var widget = _buildInputWidget(hintText, inputType, changeListener);
    return widget;
  }
}
