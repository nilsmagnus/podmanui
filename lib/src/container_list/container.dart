import 'dart:developer';

class PodContainer {
  final String containerId;
  final String image;
  final String command;
  final String created;
  final String status;
  final String ports;
  final String names;

  PodContainer(this.containerId, this.image, this.command, this.created, this.status, this.ports, this.names);

  static PodContainer fromHeaderAndLine(String header, String line) {
    return PodContainer(
      line.substring(0, header.indexOf("IMAGE")).trim(),
      line.substring(header.indexOf("IMAGE"), header.indexOf("COMMAND")).trim(),
      line.substring(header.indexOf("COMMAND"), header.indexOf("CREATED")).trim(),
      line.substring(header.indexOf("CREATED"), header.indexOf("STATUS")).trim(),
      line.substring(header.indexOf("STATUS"), header.indexOf("PORTS")).trim(),
      line.substring(header.indexOf("PORTS"), header.indexOf("NAMES")).trim(),
      line.substring(header.indexOf("NAMES")).trim(),
    );
  }

  bool get isRunning {
    log("status is ${status.toLowerCase()}, bool should be");
    return !status.toLowerCase().contains("exit");
  }
}
