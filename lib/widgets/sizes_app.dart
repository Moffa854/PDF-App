import 'package:flutter/material.dart';

num sizesApp(BuildContext context, num phone, num tablet, num desktop) {
  final size = MediaQuery.of(context).size.width;
  if (size < 450) {
    return phone;
  } else if (size > 450 && size < 1100) {
    return tablet;
  } else {
    return desktop;
  }
}

