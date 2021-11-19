import 'package:flutter/material.dart';
import 'package:podmanui/src/podmanservice.dart';

/// Displays detailed information about a SampleItem.
class ContainerDetailsView extends StatefulWidget {
  final String name;

  const ContainerDetailsView(this.name, {Key? key}) : super(key: key);

  static const routeName = '/container_details';

  @override
  State<ContainerDetailsView> createState() => _ContainerDetailsViewState();
}

class _ContainerDetailsViewState extends State<ContainerDetailsView> {
  Future<dynamic> details = Future.value([]);
  Future<String> logs = Future.value("");

  _ContainerDetailsViewState();

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    setState(() {
      details = PodmanService().inspect(widget.name);
      logs = PodmanService().logs(widget.name);
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
              Expanded(child: Text('Container ${widget.name} details')),
              IconButton(
                onPressed: () => PodmanService().stop(widget.name),
                icon: const Icon(Icons.stop),
                tooltip: "Stop",
              ),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Logs"),
              Tab(text: "Details"),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            futureView(logs),
            futureViewData(details),
          ],
        ),
      ),
    );
  }

  FutureBuilder<String> futureView(Future<String> future) {
    return FutureBuilder<String>(
      future: future,
      builder: (c, d) {
        if (d.hasData) {
          return SingleChildScrollView(child: Text("${d.data}"));
        } else if (d.hasError) {
          return Text("Some error occured: ${d.error}");
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
          return Text("Some error occured: ${d.error}");
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
      return Text("${data}");
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
