class PodmanPod {
  final String podId;
  final String name;
  final String status;
  final String created;
  final String infraId;
  final String containerCount;

  PodmanPod(this.podId, this.name, this.status, this.created, this.infraId, this.containerCount);

  static PodmanPod fromHeaderAndLine(String header, String line) {
    return PodmanPod(
      //POD ID        NAME                        STATUS      CREATED     INFRA ID      # OF CONTAINERS
      line.substring(0, header.indexOf("NAME")).trim(),
      line.substring(header.indexOf("NAME"), header.indexOf("STATUS")).trim(),
      line.substring(header.indexOf("STATUS"), header.indexOf("CREATED")).trim(),
      line.substring(header.indexOf("CREATED"), header.indexOf("INFRA ID")).trim(),
      line.substring(header.indexOf("INFRA ID"), header.indexOf("# OF CONTAINERS")).trim(),
      line.substring(header.indexOf("# OF CONTAINERS")).trim(),
    );
  }
}
