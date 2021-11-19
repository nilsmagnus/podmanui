import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:podmanui/src/podmanservice.dart';

import '../appdrawer.dart';
import '../settings/settings_view.dart';
import 'container.dart';
import 'container_details_view.dart';

class ContainerListView extends StatefulWidget {
  const ContainerListView({Key? key}) : super(key: key);

  static const routeName = '/containerlist';

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

  void refreshPs() async {
    PodmanService().ps().then((value) => setState(() {
          items = value;
          showMessage(context, "Refresh done");
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
      drawer: appDrawer(context),
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
              itemBuilder: containerItemBuilder,
            ),
    );
  }

  Widget containerItemBuilder(BuildContext context, int index) {
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
            children: containerActions(item.containerId, context, item.isRunning, refreshPs),
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
  }
}

List<Widget> containerActions(String itemId, BuildContext context, bool isRunning, Function refreshPs) {
  return [
    IconButton(
        tooltip: "Restart",
        onPressed: () async {
          PodmanService()
              .restart(itemId)
              .then(
                (value) => showMessage(context, "Restarted: ${value}"),
              )
              .whenComplete(() => refreshPs());
        },
        icon: const Icon(Icons.refresh, color: Colors.green)),
    if (isRunning)
      IconButton(
          tooltip: "Stop",
          onPressed: () async {
            PodmanService()
                .stop(itemId)
                .then((value) => showMessage(context, "Stop: ${value}"))
                .whenComplete(() => refreshPs());
          },
          icon: Icon(Icons.stop))
    else
      IconButton(
        onPressed: () {},
        tooltip: "Already stopped",
        icon: Icon(Icons.warning, color: Colors.grey.withAlpha(128)),
      ),
    IconButton(
        tooltip: "Delete",
        onPressed: () async {
          PodmanService()
              .deleteContainer(itemId)
              .then((value) => showMessage(context, value))
              .whenComplete(() => refreshPs());
        },
        icon: const Icon(Icons.delete, color: Colors.red))
  ];
}
