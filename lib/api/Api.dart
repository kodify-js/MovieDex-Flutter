import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moviedex/api/secrets.dart.local';
import 'package:moviedex/api/class/content_class.dart';
import 'package:moviedex/api/utils.dart';

class Api {
    String? baseUrl;
    Api({
        this.baseUrl = "https://api.tmdb.org"
    });
    Future fetchPopular({ required type,language})async{
        try {
            final data = await http.get(Uri.parse('$baseUrl/3/discover/${type}?api_key=$apiKey&include_video=true&language=en-US&page=1&sort_by=popularity.desc&with_original_language=$language'));
            final response = jsonDecode(data.body);
            if(response['success'] != null) throw "An unexpected error occured";
            final result = (response['results'] as List).map((movie) {
                Contentclass data = Contentclass(id: movie['id'], backdrop: imagePath(size: ImageSize.original,path: movie['backdrop_path']), title: movie['title'] ?? movie['name'], language: movie['original_language'], genres: [], type: type, description: movie['overview'], poster: 'https://wsrv.nl/?url=https://image.tmdb.org/t/p/w342${movie["poster_path"]}&output=webp');
                return data;
            }).toList();
            for(int i=0;i<5;i++){
                result[i].logoPath = await getLogo(result[i].id,type);
            }
            return result;
        } catch (e) {
            throw e.toString();
        }
}

Future getLogo(id,type) async{
    try {
        final data = await http.get(Uri.parse('$baseUrl/3/$type/$id/images?api_key=$apiKey'));
        final response = jsonDecode(data.body);
        var index=0;
        for(int i=0;i<response["logos"].length;i++){
            if(response["logos"][i]["iso_639_1"]=="en"){
                index=i;
                i=response["logos"].length;
            }
        }
        final result = imagePath(size:ImageSize.w342,path:response["logos"][index]["file_path"]);
        return result;
    } catch (error) {
        return {"error":"Can't Find Logo"};
        
    }
}

Future getCatagorylist({
  required String type, 
  required String language, 
  required int index
}) async {
  try {
      final data = await http.get(Uri.parse(
        '$baseUrl/3/discover/$type?include_adult=false&include_video=false&language=en-US&page=1&sort_by=popularity.desc&with_genres=${movieGenres[index]['id']}&api_key=$apiKey&with_original_language=$language'
      ));
      
      if (data.statusCode != 200) throw Exception("Failed to fetch data");
      
      final response = jsonDecode(data.body);
      if (response['results'] == null) throw Exception("No results found");
      
      final List<Contentclass> category = (response['results'] as List)
          .where((movie) => 
              movie['backdrop_path'] != null && 
              movie['poster_path'] != null)
          .map((movie) => Contentclass(
              id: movie['id'], 
              backdrop: imagePath(size: ImageSize.original, path: movie['backdrop_path']), 
              title: movie['title'] ?? movie['name'] ?? 'Unknown', 
              language: movie['original_language'], 
              genres: [], 
              type: type, 
              description: movie['overview'] ?? '', 
              poster: imagePath(size: ImageSize.w342, path: movie['poster_path'])
          ))
          .toList();
      
      if (category.isEmpty) throw Exception("No movies found for this category");
      return [{movieGenres[index]['name']: category}];
  } catch (e) {
      throw Exception("Failed to load category: ${e.toString()}");
  }
}

Future getDetails({required int id,required String type}) async {
  try {
      final data = await http.get(Uri.parse('$baseUrl/3/$type/$id?api_key=$apiKey&language=en-US'));
      final response = jsonDecode(data.body);
      if (response['status_code'] != null) throw Exception("Failed to fetch data");
      
      final Contentclass content = Contentclass(
          id: response['id'], 
          backdrop: imagePath(size: ImageSize.original, path: response['backdrop_path']), 
          title: response['title'] ?? response['name'] ?? 'Unknown',
          language: response['original_language'],
          genres: response['genres'].map((genre) => genre['name']).toList(),
          type: type,
          description: response['overview'] ?? '',
          poster: imagePath(size: ImageSize.original, path: response['poster_path']),
          rating: response['vote_average'],
          );
        content.logoPath = await getLogo(id,type);
        return content;
  }catch(e){
      throw Exception("Failed to load details: ${e.toString()}");
  }
  }


Future getRecommendations({required int id,required String type}) async {
  try {
      final data = await http.get(Uri.parse('$baseUrl/3/$type/$id/recommendations?api_key=$apiKey&language=en-US&page=1'));
      final response = jsonDecode(data.body);
      if (response['status_code'] != null) throw Exception("Failed to fetch data");
      
      final List<Contentclass> recommendations = (response['results'] as List)
          .where((movie) => 
              movie['backdrop_path'] != null && 
              movie['poster_path'] != null)
          .map((movie) => Contentclass(
              id: movie['id'], 
              backdrop: imagePath(size: ImageSize.original, path: movie['backdrop_path']), 
              title: movie['title'] ?? movie['name'] ?? 'Unknown',
              language: movie['original_language'],
              genres: [],
              type: type,
              description: movie['overview'] ?? '',
              poster: imagePath(size: ImageSize.w342, path: movie['poster_path'])
              )
              ).toList();
      return recommendations;      
  }catch(e){
      throw Exception("Failed to load recommendations: ${e.toString()}");
  }
  }
}