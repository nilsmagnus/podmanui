import 'package:flutter/material.dart';
import 'package:podmanui/src/image_list/image_list_view.dart';

import 'container_list/container_list_view.dart';

Drawer appDrawer(BuildContext context) => Drawer(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textButton(context, "Containers", ContainerListView.routeName),
            textButton(context, "Images", ImageListView.routeName),
          ],
        ),
      ),
    );

TextButton textButton(BuildContext context, String label, String route) {
  return TextButton(
      onPressed: () {
        Navigator.restorablePushNamed(context, route);
      },
      child: Text(label));
}

String showMessage(BuildContext context, String s) {
  if (s.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(s),
    ));
  }
  return s;
}