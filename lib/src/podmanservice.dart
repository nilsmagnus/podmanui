import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:podmanui/src/image_list/image.dart';

import 'container_list/container.dart';

class PodmanService {
  static const _platform = MethodChannel('no.nils.podmanui/desktop');

  Future<dynamic> inspect(String resourceId) async {
    return _platform.invokeMethod("podman inspect $resourceId").then((value) {
      switch (value.runtimeType) {
        case String:
          return json.decode(value as String);
      }
      return [];
    });
  }

  Future<String> logs(String resourceId) async {
    return _platform.invokeMethod("podman logs $resourceId").then((value) {
      switch (value.runtimeType) {
        case String:
          return value as String;
      }
      return "";
    });
  }

  Future<List<PodContainer>> ps() async {
    return _platform.invokeMethod("podman ps -a").then((value) {
      switch (value.runtimeType) {
        case String:
          return parsePsResult(value as String);
      }
      return List.empty();
    });
  }

  Future<List<PodmanImage>> images() async {
    return _platform.invokeMethod("podman images").then((value) {
      switch (value.runtimeType) {
        case String:
          return parseImageResult(value as String);
      }
      return List.empty();
    });
  }

  Future<String> deleteContainer(String containerId) async {
    return _platform.invokeMethod("podman rm $containerId").then((value) => "$value");
  }

  Future<String> deleteImage(String imageId) async {
    return _platform.invokeMethod("podman image rm $imageId").then((value) {
      return "${value}".trim();
    });
  }

  Future<String> restart(String containerId) async {
    return _platform.invokeMethod("podman restart $containerId").then((value) => "$value");
  }

  Future<String> stop(String containerId) async {
    return _platform.invokeMethod("podman stop $containerId").then((value) => "$value");
  }
}

List<PodmanImage> parseImageResult(String value) {
  final lines = value.split("\n");
  if (lines.length <= 1) {
    return List.empty();
  }

  // header-line
  final header = lines.removeAt(0);

  final List<PodmanImage> result = List.empty(growable: true);

  lines
      .map((line) => line.isNotEmpty ? PodmanImage.fromHeaderAndLine(header, line) : null)
      .where((element) => element != null)
      .forEach((element) {
    result.add(element!);
  });

  return result;
}

List<PodContainer> parsePsResult(String value) {
  final lines = value.split("\n");
  if (lines.length <= 1) {
    return List.empty();
  }

  // header-line
  final header = lines.removeAt(0);
  final List<PodContainer> result = List.empty(growable: true);

  lines
      .map((line) => line.isNotEmpty ? PodContainer.fromHeaderAndLine(header, line) : null)
      .where((element) => element != null)
      .forEach((element) {
    result.add(element!);
  });

  return result;
}
