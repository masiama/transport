import 'package:flutter/material.dart';
import '../timetable.dart';
import '../fetch.dart';

class UpdateButton extends StatefulWidget {
  final TimetablePageState _state;
  UpdateButton(this._state);
  
  @override
  _UpdateButtonState createState() => _UpdateButtonState();
}

class _UpdateButtonState extends State<UpdateButton> {
  static final updateText = Text('Tap to update');
  static final loadingText = Text('Updating...');
  
  static final borderRadius = const BorderRadius.all(Radius.circular(15.0));
  
  bool _visiblle = true;
  Text _text = updateText;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      left: 0.0,
      right: 0.0,
      bottom: _visiblle ? 16.0 : -50.0,
      child: Center(child: Material(
        borderRadius: borderRadius,
        color: Theme.of(context).buttonColor,
        child: InkWell(
          onTap: () async {
            setState(() => _text = loadingText);
            await updateFiles();
            setState(() => _visiblle = false);
            widget._state.rebuild();
          },
          borderRadius: borderRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
            child: _text,
          ),
        ),
      ))
    );
  }
}
