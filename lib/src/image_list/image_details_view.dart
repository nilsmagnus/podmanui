import 'package:flutter/material.dart';
import 'package:podmanui/src/podmanservice.dart';

/// Displays detailed information about a SampleItem.
class ImageDetailsView extends StatefulWidget {
  final String name;

  const ImageDetailsView(this.name, {Key? key}) : super(key: key);

  static const routeName = '/pod_details';

  @override
  State<ImageDetailsView> createState() => _ImageDetailsViewState();
}

class _ImageDetailsViewState extends State<ImageDetailsView> {
  Future<Map<String, dynamic>> details = Future.value({});
  Future<String> logs = Future.value("");

  _ImageDetailsViewState();

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    setState(() {
      //details = PodmanService().inspect(widget.name);
      logs = PodmanService().logs(widget.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          tooltip: "Refresh",
          onPressed: refresh,
        ),
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(child: Text('${widget.name} details')),
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
              Tab(icon: Icon(Icons.directions_bike)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            futureView(logs),
            Text("TODO details"),
            Icon(Icons.directions_bike),
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

  FutureBuilder<Map<String, dynamic>> futureViewMap(Future<Map<String, dynamic>> future) {
    return FutureBuilder<Map<String, dynamic>>(
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
}
