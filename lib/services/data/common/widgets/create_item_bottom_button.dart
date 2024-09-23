import 'package:flutter/material.dart';

class CreateItemBottomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonText;

  const CreateItemBottomButton({
    Key? key,
    required this.onPressed,
    required this.buttonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 30.0),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          child: Text(buttonText),
        ),
      ),
    );
  }
}