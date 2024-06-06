import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Function(dynamic value)? method; // Callback for text changes
  final String? initialValue;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.icon,
    this.obscureText = false, // Default to not obscure
    this.keyboardType,
    this.method,
    this.initialValue,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue);

    // Add listener if method is provided
    if (widget.method != null) {
      _textController.addListener(_onTextChanged);
    }

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Call the provided method with the current text value
    widget.method?.call(_textController.text);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mq.size.width * 0.05),
      child: TextField(
        obscureText: widget.obscureText,
        focusNode: _focusNode,
        controller: _textController, // Use the created controller
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 149, 157, 163), width: 2.0),
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