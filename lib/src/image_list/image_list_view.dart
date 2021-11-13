import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:podmanui/src/podmanservice.dart';

import '../settings/settings_view.dart';
import 'image.dart';
import 'image_details_view.dart';

class ImageListView extends StatefulWidget {
  const ImageListView({Key? key}) : super(key: key);

  static const routeName = '/imageList';

  @override
  State<ImageListView> createState() => _ImageListViewState();
}

class _ImageListViewState extends State<ImageListView> {
  List<PodmanImage> items = [];

  @override
  void initState() {
    super.initState();
    log("init");
    refreshImages();
  }

  void refreshImages() {
    PodmanService().images().then((value) => setState(() {
          items = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        tooltip: "Refresh",
        onPressed: refreshImages,
      ),
      appBar: AppBar(
        title: const Text('podman ps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(child: Text("No running containers"))
          : ListView.builder(
              restorationId: 'containerListView',
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return ListTile(
                    title: Text('${item.imageId}'),
                    leading: const CircleAvatar(
                      foregroundImage: AssetImage('assets/images/flutter_logo.png'),
                    ),
                    subtitle: Row(
                      children: [
                        Text(" TODO"),
                      ],
                    ),
                    trailing: Text(item.tag),
                    onTap: () {
                      Navigator.restorablePushNamed(
                        context,
                        ImageDetailsView.routeName,
                        arguments: item.imageId,
                      );
                    });
              },
            ),
    );
  }
}
