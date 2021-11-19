import 'package:flutter/material.dart';
import 'package:podmanui/src/container_list/container_details_view.dart';
import 'package:podmanui/src/container_list/container_list_view.dart';
import 'package:podmanui/src/podmanservice.dart';

/// Displays detailed information about a SampleItem.
class PodDetailsView extends StatefulWidget {
  final String name;

  const PodDetailsView(this.name, {Key? key}) : super(key: key);

  static const routeName = '/pod_details';

  @override
  State<PodDetailsView> createState() => _PodDetailsViewViewState();
}

class _PodDetailsViewViewState extends State<PodDetailsView> {
  Future<dynamic> details = Future.value([]);

  _PodDetailsViewViewState();

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    setState(() {
      details = PodmanService().inspect(widget.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          tooltip: "Refresh",
          onPressed: refresh,
        ),
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(child: Text('Pod ${widget.name} details')),
              IconButton(
                onPressed: () => PodmanService().stop(widget.name),
                icon: const Icon(Icons.stop),
                tooltip: "Stop",
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Containers in pod "),
              Tab(text: "Details"),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            FutureBuilder<dynamic>(
              future: details,
              builder: (c, d) {
                if (d.hasData) {
                  return containersInPod(d.data);
                } else {
                  return const Text("Loading");
                }
              },
            ),
            futureViewData(details),
          ],
        ),
      ),
    );
  }

  Widget containersInPod(dynamic details) {
    final pods = ((((details as List<dynamic>)[0]) as Map<String, dynamic>)["Containers"] as List);
    return ListView.builder(
      itemBuilder: (c, i) {
        final item = pods[i];
        if (item is Map<String, dynamic>) {
          return ListTile(
            onTap: () {
              Navigator.restorablePushNamed(
                context,
                ContainerDetailsView.routeName,
                arguments: item["Id"],
              );
            },
            leading: Text("${item["Name"]} ", style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: SizedBox(
              width: 130,
              child: Row(
                children:
                    containerActions(item["Id"] as String, c, (item["State"] as String).contains("running"), refresh),
              ),
            ),
          );
        } else {
          return Text("WTF!!!! $item (${item.runtimeType})");
        }
      },
      itemCount: pods.length,
    );
  }

  FutureBuilder<String> futureView(Future<String> future) {
    return FutureBuilder<String>(
      future: future,
      builder: (c, d) {
        if (d.hasData) {
          return SingleChildScrollView(child: Text("${d.data}"));
        } else if (d.hasError) {
          return Text("Some error occurred: ${d.error}");
        }
        return Center(child: Text("Fetching info for ${widget.name}..."));
      },
    );
  }

  FutureBuilder<dynamic> futureViewData(Future<dynamic> future) {
    return FutureBuilder<dynamic>(
      future: future,
      builder: (c, d) {
        if (d.hasData) {
          return SingleChildScrollView(child: DataViewer(d.data[0]!));
        } else if (d.hasError) {
          return Text("Some error occurred: ${d.error}");
        }
        return Center(child: Text("Fetching info for ${widget.name}..."));
      },
    );
  }
}

class DataViewer extends StatelessWidget {
  final dynamic data;

  const DataViewer(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Text("");
    } else if (data is String || data is int || data is bool || data is double) {
      return Text("$data");
    } else if (data is List) {
      return Row(children: (data as List).map((e) => (DataViewer(e))).toList());
    } else if (data is Map) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: (data as Map)
              .entries
              .map((e) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: (Row(
                      children: [
                        Text("${e.key}: "),
                        DataViewer(e.value),
                      ],
                    )),
                  ))
              .toList());
    }
    return Text("I dont handle ${data.runtimeType}");
  }
}
