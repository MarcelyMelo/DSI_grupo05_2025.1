import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
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

  const MyTextField(
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
                  color: Colors.white,
                ),
              ),
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.blue),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }
}
