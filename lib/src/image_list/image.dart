class PodmanImage {
  final String repository;
  final String tag;
  final String imageId;
  final String created;
  final String size;

  PodmanImage(this.repository, this.tag, this.imageId, this.created, this.size);

  static PodmanImage fromHeaderAndLine(String header, String line) {
    return PodmanImage(
      line.substring(0, header.indexOf("TAG")),
      line.substring(header.indexOf("TAG"), header.indexOf("IMAGE ID")),
      line.substring(header.indexOf("IMAGE ID"), header.indexOf("CREATED")),
      line.substring(header.indexOf("CREATED"), header.indexOf("SIZE")),
      line.substring(
        header.indexOf("SIZE"),
      ),
    );
  }
}
