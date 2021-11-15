import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:podmanui/src/podmanservice.dart';

import '../appdrawer.dart';
import '../settings/settings_view.dart';
import 'image.dart';

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
      drawer: appDrawer(context),
      appBar: AppBar(
        title: const Text('podman images'),
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
          ? const Center(child: Text("No images found"))
          : ListView.builder(
              restorationId: 'imageListView',
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return ListTile(
                  title: Text('${item.repository}'),
                  subtitle: Text("${item.tag} ${item.imageId} ${item.created}"),
                  trailing: SizedBox(
                    width: 120,
                    child: Row(
                      children: [
                        Text(item.size),
                        IconButton(
                          onPressed: () {
                            PodmanService()
                                .deleteImage(item.imageId)
                                .onError((error, stackTrace) => showMessage(context, "Error removing image: $error"))
                                .then((value) => showMessage(context, value))
                                .whenComplete(() => refreshImages());
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
