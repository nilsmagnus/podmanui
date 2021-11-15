import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:podmanui/src/image_list/image.dart';
import 'package:podmanui/src/pod_list/podmanpod.dart';

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
          return parseResult(value as String, PodContainer.fromHeaderAndLine);
      }
      return List.empty();
    });
  }

  Future<List<PodmanImage>> images() async {
    return _platform.invokeMethod("podman images").then((value) {
      switch (value.runtimeType) {
        case String:
          return parseResult<PodmanImage>(value as String, PodmanImage.fromHeaderAndLine);
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

  Future<String> restartPod(String containerId) async {
    return _platform.invokeMethod("podman pod restart $containerId").then((value) => "$value");
  }

  Future<String> stop(String containerId) async {
    return _platform.invokeMethod("podman stop $containerId").then((value) => "$value");
  }

  Future<String> stopPod(String containerId) async {
    return _platform.invokeMethod("podman pod stop $containerId").then((value) => "$value");
  }

  Future<String> deletePod(String containerId) async {
    return _platform.invokeMethod("podman pod rm $containerId").then((value) => "$value");
  }

  Future<List<PodmanPod>> pods() async {
    return _platform.invokeMethod("podman pod ls").then((value) {
      switch (value.runtimeType) {
        case String:
          return parseResult<PodmanPod>(value as String, PodmanPod.fromHeaderAndLine);
      }
      return List.empty();
    });

    return List.empty();
  }
}

List<T> parseResult<T>(String value, T Function(String, String) parse) {
  final lines = value.split("\n");
  if (lines.length <= 1) {
    return List.empty();
  }

  // header-line
  final header = lines.removeAt(0);

  return lines
      .map((line) => line.isNotEmpty ? parse(header, line) : null)
      .where((element) => element != null)
      .map((e) => e!)
      .toList();
}
