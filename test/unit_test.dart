import 'package:flutter_test/flutter_test.dart';
import 'package:podmanui/src/container_list/container.dart';
import 'package:podmanui/src/podmanservice.dart';

void main() {
  group('Podman service test', () {
    test('parse podman ps output', () {
      const rawLines =
          """CONTAINER ID  IMAGE                            COMMAND     CREATED     STATUS         PORTS                   NAMES
b2b57b6be362  docker.io/library/postgres:13.4  postgres    9 days ago  Up 9 days ago  0.0.0.0:5432->5432/tcp  autopp_local_db

""";
      final pods = parseResult<PodContainer>(rawLines, PodContainer.fromHeaderAndLine);
      expect(1, pods.length);
      expect("b2b57b6be362", pods[0].containerId);
      expect("docker.io/library/postgres:13.4", pods[0].image);
      expect("postgres", pods[0].command);
      expect("9 days ago", pods[0].created);
      expect("Up 9 days ago", pods[0].status);
      expect("0.0.0.0:5432->5432/tcp", pods[0].ports);
      expect("autopp_local_db", pods[0].names);
    });
  });
}
