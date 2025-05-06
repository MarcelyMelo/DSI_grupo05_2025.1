import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:flutter/material.dart';

class TextFieldRegister extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final bool? isPassword;
  final bool? isEmail;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Function()? onSuffixTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? hintText;

  const TextFieldRegister(
      {super.key,
      this.controller,
      this.label,
      this.isPassword = false,
      this.isEmail = false,
      this.keyboardType,
      this.prefixIcon,
      this.suffixIcon,
      this.onSuffixTap,
      this.validator,
      this.onChanged,
      this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        color: Colors.black,
      ),
      controller: controller,
      obscureText: isPassword!,
      keyboardType: keyboardType,
      validator: (value) {
        if (value!.length < 4) {
          return "Deve ter pelo menos 4 caracteres";
        }
        if (value.isEmpty) {
          return "Campo não pode estar vazio";
        }
        if (isEmail! && !value.contains("@")) {
          return "Digite um email válido";
        }

        return null;
      },
      onChanged: onChanged,
      decoration: InputDecoration(
        label: label == null
            ? null
            : Text(
                label!,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.black,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.blue),
        ),
        fillColor: Colors.transparent,
        filled: true,
      ),
    );
  }
}
