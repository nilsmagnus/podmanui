import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:podmanui/src/podmanservice.dart';

import '../settings/settings_view.dart';
import 'container.dart';
import 'container_details_view.dart';

class ContainerListView extends StatefulWidget {
  const ContainerListView({Key? key}) : super(key: key);

  static const routeName = '/podlist';

  @override
  State<ContainerListView> createState() => _ContainerListViewState();
}

class _ContainerListViewState extends State<ContainerListView> {
  List<PodContainer> items = [];

  @override
  void initState() {
    super.initState();
    log("init");
    refreshPs();
  }

  void refreshPs() {
    PodmanService().ps().then((value) => setState(() {
          items = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        tooltip: "Refresh",
        onPressed: refreshPs,
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
                    title: Text('${item.image} (${item.names})  ${item.status}'),
                    leading: CircleAvatar(
                      child: Text(item.image.substring(0, 2)),
                    ),
                    subtitle: Text(" Command '${item.command}' created ${item.created} with ports '${item.ports}'"),
                    trailing: SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              tooltip: "Restart",
                              onPressed: () async {
                                await PodmanService().restart(item.containerId);
                                refreshPs();
                              },
                              icon: Icon(Icons.refresh)),
                          IconButton(
                              tooltip: "Stop",
                              onPressed: () async {
                                await PodmanService().stop(item.containerId);
                                refreshPs();
                              },
                              icon: Icon(Icons.stop)),
                          IconButton(
                              tooltip: "Delete",
                              onPressed: () async {
                                await PodmanService().delete(item.containerId);
                                refreshPs();
                              },
                              icon: Icon(Icons.delete))
                        ],
                      ),
                    ),
                    onLongPress: () {
                      log("longpress");
                    },
                    onTap: () {
                      Navigator.restorablePushNamed(
                        context,
                        ContainerDetailsView.routeName,
                        arguments: item.containerId,
                      );
                    });
              },
            ),
    );
  }
}
