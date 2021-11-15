import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:podmanui/src/pod_list/pod_details_view.dart';
import 'package:podmanui/src/pod_list/podmanpod.dart';
import 'package:podmanui/src/podmanservice.dart';

import '../appdrawer.dart';
import '../settings/settings_view.dart';

class PodListView extends StatefulWidget {
  const PodListView({Key? key}) : super(key: key);

  static const routeName = '/podlist';

  @override
  State<PodListView> createState() => _PodListViewState();
}

class _PodListViewState extends State<PodListView> {
  List<PodmanPod> items = [];

  @override
  void initState() {
    super.initState();
    refreshPods();
  }

  void refreshPods() {
    PodmanService().pods().then((value) => setState(() {
          items = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.refresh),
        tooltip: "Refresh",
        onPressed: refreshPods,
      ),
      drawer: appDrawer(context),
      appBar: AppBar(
        title: const Text('podman pod ls'),
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
          ? const Center(child: Text("No pods"))
          : ListView.builder(
              restorationId: 'podListView',
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return ListTile(
                    title: Text('${item.name} (${item.podId})  ${item.status}'),
                    leading: CircleAvatar(
                      child: Text(item.infraId.substring(0, 2)),
                    ),
                    subtitle:
                        Text(" Command '${item.status}' created ${item.created} with ports '${item.containerCount}'"),
                    trailing: SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              tooltip: "Restart",
                              onPressed: () async {
                                PodmanService()
                                    .restartPod(item.podId)
                                    .then((value) => showMessage(context, value))
                                    .whenComplete(() => refreshPods());
                              },
                              icon: Icon(Icons.refresh)),
                          IconButton(
                              tooltip: "Stop",
                              onPressed: () async {
                                PodmanService()
                                    .stopPod(item.podId)
                                    .then((value) => showMessage(context, value))
                                    .whenComplete(() => refreshPods());
                              },
                              icon: Icon(Icons.stop)),
                          IconButton(
                              tooltip: "Delete",
                              onPressed: () async {
                                PodmanService()
                                    .deletePod(item.podId)
                                    .then((value) => showMessage(context, value))
                                    .whenComplete(() => refreshPods());
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
                        PodDetailsView.routeName,
                        arguments: item.podId,
                      );
                    });
              },
            ),
    );
  }
}
