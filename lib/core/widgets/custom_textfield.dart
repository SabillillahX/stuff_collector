import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final String label;
  final bool hasError;
  final String? errorText;
  final String? Function()? validator;
  final Function(String)? onChanged;
  final bool autoClear; // Auto clear field after successful login

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.label,
    this.isPassword = false,
    this.hasError = false,
    this.errorText,
    this.validator,
    this.onChanged,
    this.autoClear = false,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (!_isFocused && widget.validator != null) {
      _validateField();
    }
  }

  void _onTextChanged() {
    if (_currentError != null && widget.controller.text.isNotEmpty) {
      setState(() {
        _currentError = null;
      });
    }
    
    // Call external onChanged callback
    widget.onChanged?.call(widget.controller.text);
  }

  void _validateField() {
    if (widget.validator != null) {
      setState(() {
        _currentError = widget.validator!();
      });
    }
  }

  // Method to clear field (can be called externally)
  void clearField() {
    widget.controller.clear();
    setState(() {
      _currentError = null;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color blueColor = Color(0xFF011936);
    const Color errorColor = Colors.red;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 12.0 : 14.0;
    
    final hasCurrentError = _currentError != null || widget.hasError;
    final errorMessage = _currentError ?? widget.errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label above the TextField
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
            color: hasCurrentError
                ? errorColor
                : (_isFocused ? blueColor : Colors.black87),
          ),
        ),
        const SizedBox(height: 4),
        // TextField with focus detection and error state
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _isObscured : false,
          focusNode: _focusNode,
          style: TextStyle(fontSize: fontSize),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(fontSize: fontSize - 1, color: Colors.grey[500]),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth < 600 ? 12.0 : 14.0,
              vertical: screenWidth < 600 ? 12.0 : 14.0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasCurrentError ? errorColor : blueColor,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: hasCurrentError ? errorColor : Colors.grey[300]!,
                width: 1.0,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            errorText: hasCurrentError ? errorMessage : null,
            errorStyle: TextStyle(color: errorColor, fontSize: fontSize - 2),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off : Icons.visibility,
                      color: hasCurrentError ? errorColor : Colors.grey[600],
                      size: screenWidth < 600 ? 16 : 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
