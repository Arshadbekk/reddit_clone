import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class loader extends StatelessWidget {
  const loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Colors.red,
      ),
    );
  }
}
