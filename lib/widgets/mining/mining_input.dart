import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kol_miner/widgets/platformui.dart';

/// Edittext and button that lets the user mine
class MiningInputFields extends StatelessWidget {
  MiningInputFields(this.advsToMineController, this.enable, this.onMineClicked);

  final VoidCallback onMineClicked;
  final TextEditingController advsToMineController;
  final bool enable;

  void _onMineClicked() {
    if (enable) {
      onMineClicked();
    }
  }

  void _onKeyboardSubmit(String a) {
    if (enable) {
      onMineClicked();
    }
  }

  @override
  Widget build(BuildContext context) {
    var mainColumn = Column(
      children: <Widget>[
        new TextField(
          controller: advsToMineController,
          decoration:
              new InputDecoration(helperText: "How many adventure to mine"),
          enabled: enable,
          keyboardType: TextInputType.numberWithOptions(),
          onSubmitted: _onKeyboardSubmit,
        ),
        new Padding(padding: EdgeInsets.only(top: 10.0)),
        getPlatformButton(
          context,
          onPressed: _onMineClicked,
          child: new Text(
            'Increment some counters instead of playing the game',
          ),
          color: Theme.of(context).primaryColor,
        )
      ],
    );
    advsToMineController.text = "10";
    return mainColumn;
  }
}
