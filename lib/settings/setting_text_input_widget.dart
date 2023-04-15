import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Edittext that lets users enter savable settings
class SettingTextInputField extends StatelessWidget {
  SettingTextInputField(this.hintText, this.inputType, this.changeListener,
      this.textEditingController, this.maxLength,{
        this.minLines: 1, this.maxLines: 1
      });

  final String hintText;
  final TextInputType inputType;
  final ValueChanged<String> changeListener;
  final int maxLength;
  final int minLines;
  final int maxLines;

  final TextEditingController textEditingController;

  Widget _buildInputWidget(String hintText, TextInputType inputType,
      ValueChanged<String> changeListener, int maxLength, {
        minLines: 1, maxLines: 1
  }) {
    return Flexible(
      child: Container(
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
              color: Colors.black, // set border color
              width: 0.8),
          borderRadius: BorderRadius.all(Radius.zero),
        ),
        child: Focus(
          onFocusChange: (hasFocus) {
            var text = textEditingController.text;
            changeListener.call(text);
          },
          child: Builder(builder: (BuildContext context) {
            return new TextField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(maxLength),
              ],
              cursorColor: Colors.indigo,
              decoration: new InputDecoration.collapsed(
                hintText: hintText,
              ),
              enabled: true,
              keyboardType: inputType,
              controller: textEditingController,
              minLines: minLines,
              maxLines: maxLines,
            );
          }),
        ),
      ),
    );
  }

  /*
              return new TextField(
              maxLength: maxLength,
              cursorColor: Colors.indigo,
              decoration: new InputDecoration(
                isCollapsed: true,
                counterText: '',
                hintText: hintText,
              ),

      return Focus(
      autofocus: autofocus,
      child: Builder(builder: (BuildContext context) {
        // The contents of this Builder are being made focusable. It is inside
        // of a Builder because the builder provides the correct context
        // variable for Focus.of() to be able to find the Focus widget that is
        // the Builder's parent. Without the builder, the context variable used
        // would be the one given the FocusableText build function, and that
        // would start looking for a Focus widget ancestor of the FocusableText
        // instead of finding the one inside of its build function.
        return Container(
          padding: const EdgeInsets.all(8.0),
          // Change the color based on whether or not this Container has focus.
          color: Focus.of(context).hasPrimaryFocus ? Colors.black12 : null,
          child: Text(data),
        );
      }),
    );
   */

  @override
  Widget build(BuildContext context) {
    var widget =
        _buildInputWidget(hintText, inputType, changeListener, maxLength, minLines: minLines, maxLines: maxLines);
    return widget;
  }
}
