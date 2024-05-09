import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final TextEditingController? controller;
  final bool obscureText; // Rename this to reflect its purpose

  const CustomTextField({
    Key? key,
    required this.hintText,
    this.icon,
    this.controller,
    required this.obscureText,
    TextInputType? keyboardType,
    Null Function(dynamic value)? method,
    String? initialValue, // Use this to control obscureText
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mq.size.width * 0.05),
      child: TextField(
        obscureText: widget.obscureText, // Use widget.obscureText here
        focusNode: _focusNode,
        controller: widget.controller,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: const Color.fromARGB(255, 149, 157, 163), width: 2.0),
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2.0),
            borderRadius: BorderRadius.circular(20),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(widget.icon),
          suffixIcon: widget
                  .obscureText // Use widget.obscureText to conditionally show the visibility toggle
              ? IconButton(
                  icon: Icon(
                    _isFocused ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFocused = !_isFocused;
                    });
                  },
                )
              : null,
          prefixIconColor: Colors.grey[500],
          suffixIconColor: Colors.grey[500],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
