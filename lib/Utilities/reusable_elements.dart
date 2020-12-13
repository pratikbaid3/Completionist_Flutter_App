import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:neumorphic/neumorphic.dart';

final Color accentColor = Color(0xff393e46);
final Color backgroundColor = Color(0xff222831);

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);
final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);
final kBoxDecorationStyle = BoxDecoration(
  color: Color(0xFF393E46),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Color(0xFF393E46),
      blurRadius: 2.0,
      offset: Offset(0, 1),
    ),
  ],
);

//TextField for email and other input
class kReusableTextField extends StatefulWidget {
  kReusableTextField(
      {@required this.columnLabel,
      @required this.textFieldIcon,
      @required this.emptyTextWarning,
      @required this.hintText,
      @required this.onChangeText});

  final String columnLabel;
  final Icon textFieldIcon;
  final String emptyTextWarning;
  final String hintText;
  final Function onChangeText;

  @override
  _kReusableTextFieldState createState() => _kReusableTextFieldState();
}

class _kReusableTextFieldState extends State<kReusableTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.columnLabel,
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            onChanged: widget.onChangeText,
            cursorColor: Colors.white,
            validator: (value) =>
                value.isEmpty ? widget.emptyTextWarning : null,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: widget.textFieldIcon,
              hintText: widget.hintText,
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }
}

//TextField for password and other obscured input
class kReusablePasswordTextField extends StatefulWidget {
  kReusablePasswordTextField(
      {@required this.columnLabel,
      @required this.textFieldIcon,
      @required this.emptyTextWarning,
      @required this.hintText,
      @required this.onChangeText});

  final String columnLabel;
  final Icon textFieldIcon;
  final String emptyTextWarning;
  final String hintText;
  final Function onChangeText;

  @override
  _kReusablePasswordTextFieldState createState() =>
      _kReusablePasswordTextFieldState();
}

class _kReusablePasswordTextFieldState
    extends State<kReusablePasswordTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.columnLabel,
          style: kLabelStyle,
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextFormField(
            onChanged: widget.onChangeText,
            cursorColor: Colors.white,
            validator: (value) =>
                value.isEmpty ? widget.emptyTextWarning : null,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: widget.textFieldIcon,
              hintText: widget.hintText,
              hintStyle: kHintTextStyle,
            ),
          ),
        )
      ],
    );
  }
}
