import 'package:flutter/material.dart';

/// The standard Autocomplete widget can't show a hint
/// To show a hint I need to override the fieldViewBuilder
class AutoCompleteUsernameInput extends StatelessWidget {
  const AutoCompleteUsernameInput(this._usernames, this._host, {Key? key})
      : super(key: key);

  final List<String>? _usernames;
  final AutoCompleteUsernameInputHost _host;

  @override
  Widget build(BuildContext context) {
       return Autocomplete<String>(
          fieldViewBuilder: getAutoCompleteField,
          optionsBuilder: (TextEditingValue textEditingValue) {
            if(_usernames == null) {
              return List.empty(growable: false);
            }
            if (textEditingValue.text == '') {
              return _usernames!;
            }
            return _usernames!.where((String option) {
              return option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase());
            });
          },
          onSelected: _host.onUsernameSelected,
        );
  }

  Widget getAutoCompleteField(BuildContext context,
      TextEditingController textEditingController,
  FocusNode focusNode,
      VoidCallback onFieldSubmitted) {
    return new _AutocompleteField(
      focusNode: focusNode,
      textEditingController: textEditingController,
      onFieldSubmitted: onFieldSubmitted,
    textChangedListener: _onTextChanged,);
  }

  void _onTextChanged(String newText) {
    _host.onTextChanged(newText);
  }
}

/// the thing that lets us show a hint (By overriding the decoration)
class _AutocompleteField extends StatelessWidget {
  const _AutocompleteField({
    Key? key,
    required this.focusNode,
    required this.textEditingController,
    required this.onFieldSubmitted,
    required this.textChangedListener
  }) : super(key: key);

  final FocusNode focusNode;

  final VoidCallback onFieldSubmitted;

  final TextEditingController textEditingController;
  final ValueChanged<String> textChangedListener;

  void _onTextChanged(String newText) {
    textChangedListener.call(newText);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: _onTextChanged,
      controller: textEditingController,
      focusNode: focusNode,
      decoration: new InputDecoration(
          hintText: "Username", suffixIcon: new Icon(Icons.person)),
      onFieldSubmitted: (String value) {
        onFieldSubmitted();
      },
    );
  }
}

abstract class AutoCompleteUsernameInputHost {
  /// called when a username is selected by ime or tap (tap seems flaky af)
  onUsernameSelected(String username);
  /// Called whenever the text is edited- this helps us when a new username is being added
  onTextChanged(String newText);
}
