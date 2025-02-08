import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:moviedex/api/class/source_class.dart';
import 'package:moviedex/api/class/stream_class.dart';

class Autoembed {
  final int id;
  const Autoembed({required this.id});

  Future<List<StreamClass>> getStream() async {
    try {
      final response = await http.get(Uri.parse('https://simple-proxy.metalewis21.workers.dev/?destination=https://hin.autoembed.cc/movie/$id'));
      final script = (response.body.toString()).split("sources:")[1];
      final List source = jsonDecode('${script.split("],")[0]}]');
      final result = source.map((data) async {
      List<SourceClass> sources = await _getSources(url: data['file']);
      return StreamClass(language: data['label'], sources: sources);
      }).toList();
      if(result.isEmpty) throw "An unexpected error occured";
      return Future.wait(result);
    } catch (e) {
      throw Exception("Failed to load video: ${e.toString()}");
    }
  }

  Future<List<SourceClass>> _getSources({required String url}) async {
    try {
      final response = await http.get(Uri.parse(url));
      final data = response.body.split("./");
      final result = data.where((url) => url.contains(".m3u8")).map((link) {
      return SourceClass(quality: link.split("/")[0], url: '${url.split('/index.m3u8')[0]}/${link.split('\n')[0]}');
    }).toList();
    return result;
    } catch (e) {
      throw Exception("Failed to load video: ${e.toString()}");
    }
  }
}