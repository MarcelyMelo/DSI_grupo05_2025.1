import 'package:dsi_projeto/components/colors/appColors.dart';
import 'package:flutter/material.dart';

class MySignInButton extends StatelessWidget {
  final Function() onTap;
  const MySignInButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 100),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          "Entrar",
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
